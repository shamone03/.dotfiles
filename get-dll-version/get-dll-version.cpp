#include <iostream>
#include <filesystem>
#include <string>
#include <windows.h>
#include <locale>
#include <fstream>
#include <ranges>

#pragma comment( lib, "Version.lib" )

/// <summary>
/// (windows only) helper function to read just the version from the file properties
/// </summary>
/// <param name="path">path to the dll file</param>
/// <returns>optional string major.minor.patch.revision if the version numbers were read successfully 
/// could possibly be 0.0.0.0 if the version did not get embedded</returns>
static std::optional<std::string> GetVersion( const std::filesystem::path& path )
{
	DWORD fileHandle = 0;
	DWORD versionDataSize = GetFileVersionInfoSize( path.c_str(), &fileHandle );

	if( versionDataSize != NULL )
	{
		auto versionData = std::make_unique<std::uint8_t[]>( versionDataSize );

		if( GetFileVersionInfo( path.c_str(), fileHandle, versionDataSize, versionData.get() ) != 0 )
		{
			UINT size = 0;
			LPVOID queryBuffer = NULL;
			// the query is the same path as in the version.rc file
			if( VerQueryValue( versionData.get(), L"\\", &queryBuffer, &size ) )
			{
				if( size != 0 )
				{
					const auto fileInfo = std::bit_cast<VS_FIXEDFILEINFO*>(queryBuffer);
					if( fileInfo->dwSignature == 0xfeef04bd )
					{
						std::string version;
						// move first 16 bits to right and zero out first 16 bits
						version += std::to_string( static_cast<std::uint16_t>((fileInfo->dwFileVersionMS >> 16) & 0x0000ffff) ) + ".";
						version += std::to_string( static_cast<std::uint16_t>((fileInfo->dwFileVersionMS >> 00) & 0x0000ffff) ) + ".";
						version += std::to_string( static_cast<std::uint16_t>((fileInfo->dwFileVersionLS >> 16) & 0x0000ffff) ) + ".";
						version += std::to_string( static_cast<std::uint16_t>((fileInfo->dwFileVersionLS >> 00) & 0x0000ffff) );

						return version;
					}
				}
			}
		}
	}
	return {};
};

/// <summary>
/// (windows only) helper function to read the product name from the file properties
/// </summary>
/// <param name="path">path to the dll file</param>
/// <returns>optional string if the product name was read successfully
/// could possibly be empty string if the name did not get embedded</returns>
static std::optional<std::wstring> GetProductName( const std::filesystem::path& path )
{
	DWORD fileHandle = 0;
	DWORD versionDataSize = GetFileVersionInfoSize( path.c_str(), &fileHandle );
	std::optional<std::string> name = std::nullopt;
	if( versionDataSize != NULL )
	{
		auto versionData = std::make_unique<std::uint8_t[]>( versionDataSize );

		if( GetFileVersionInfo( path.c_str(), fileHandle, versionDataSize, versionData.get() ) != 0 )
		{
			LPVOID queryBuffer = NULL;
			UINT size = 0;
			// LPVOID is a void*
			if( VerQueryValue( versionData.get(), L"\\StringFileInfo\\040904E4\\ProductName", &queryBuffer, &size ) )
			{
				if( size != 0 )
				{
					const auto productName = std::bit_cast<wchar_t*>(queryBuffer);
					if( productName )
					{
						return std::wstring( productName, size );
					}
				}
			}
			size = 0;
			queryBuffer = NULL;
			// same thing but different codepage
			if( VerQueryValue( versionData.get(), L"\\StringFileInfo\\100904B0\\ProductName", &queryBuffer, &size ) )
			{
				if( size != 0 )
				{
					const auto productName = std::bit_cast<wchar_t*>(queryBuffer);
					if( productName )
					{
						return std::wstring( productName, size );
					}
				}
			}
		}

	}
	return {};
}

/// <summary>
/// moves iterator to end of substring
/// </summary>
/// <param name="haystack">[out] the iterator to search in</param>
/// <param name="needle">the string to search for</param>
static void MoveToSubstrEnd( std::istreambuf_iterator<char> haystack, std::string_view needle )
{
	auto j = needle.cbegin();
	for( auto i = haystack; i != std::istreambuf_iterator<char>(); i++ )
	{
		if( *i == *j )
		{
			j++;
		}
		else
		{
			j = needle.cbegin();
		}
		if( j == needle.cend() )
		{
			return; // can return at end of match because we don't care about when it started
		}
	}
}

/// <summary>
/// Try getting dll information from the cartenav embedded string inside a dll
/// </summary>
/// <param name="path">path to the dll file</param>
/// <returns>optional string if the file was read successfully and had the cartenav embedded string</returns>
static std::optional<std::string> GetDllInfoFromFile( const std::filesystem::path& path )
{
	const auto endsWith = []( std::string_view test, std::string_view with )
		{
			if( test.size() >= with.size() )
			{
				return test.substr( test.size() - with.size(), with.size() ) == with;
			}
			return false;
		};

	auto handle = std::ifstream( path, std::ios::binary );
	auto start = std::istreambuf_iterator<char>( handle );
	MoveToSubstrEnd( start, "__CARTENAV_PKG_" );

	const auto eof = std::istreambuf_iterator<char>();
	if( start != eof )
	{
		// remove first underscore
		start++;

		std::string version;

		while( !endsWith( version, "__" ) && start != eof )
		{
			version.push_back( *(start++) );
		}

		// remove last 2 underscores
		if( version.size() >= 2 )
		{
			version.erase( version.end() - 2, version.end() );
		}

		return version.size() > 0 ? std::optional( version ) : std::nullopt;
	}
	return {};
}

/// <summary>
/// (platform) Try getting dll information from the file properties which will exist if it was built with cmake-tools >= 3.3.1
/// </summary>
/// <param name="path">path to the dll file</param>
/// <returns>optional string if the file had the dll properties</returns>
static std::optional<std::pair<std::wstring, std::string>> GetDllInfoFromVersionInfo( const std::filesystem::path& path )
{
	const auto version = GetVersion( path );
	if( !version.has_value() )
	{
		return std::nullopt;
	}
	return std::pair{ GetProductName( path ).value_or( path.filename().wstring() ), *version };
}

enum SearchMode
{
	File = 0,
	Prop,
	Either
};

enum Warn
{
	None = 0,
	All
};

int main( int argc, char** argv )
{
	SearchMode mode = SearchMode::Either;
	Warn level = Warn::None;
	for( int i = 1; i < argc; i++ )
	{
		const auto arg = std::string( argv[i] );
		if( arg == "-h" )
		{
			std::cout << "-a: " << "print all warnings" << std::endl;
			std::cout << "-p: " << "search in properties only" << std::endl;
			std::cout << "-f: " << "search in file only" << std::endl;
			break;
		}
	}

	for( int i = 1; i < argc; i++ )
	{
		const auto arg = std::string( argv[i] );
		if( arg == "-a" )
		{
			level = Warn::All;
			break;
		}
	}
	for( int i = 1; i < argc; i++ )
	{
		const auto arg = std::string( argv[i] );
		if( arg == "-f" )
		{
			mode = SearchMode::File;
			break;
		}
		if( arg == "-p" )
		{
			mode = SearchMode::Prop;
			break;
		}
	}

	for( int i = 1; i < argc; i++ )
	{
		const auto arg = std::string( argv[i] );
		if( std::filesystem::exists( arg ) )
		{
			switch( mode )
			{
				case SearchMode::File:
				{
					const auto version = GetDllInfoFromFile( arg );
					if( version.has_value() )
					{
						std::cout << *version << std::endl;
					}
					else if( level == Warn::All )
					{
						std::cout << "Could not find product or version info for " << arg << std::endl;
					}
					break;
				}
				case SearchMode::Prop:
				{
					const auto version = GetDllInfoFromVersionInfo( arg );
					if( version.has_value() )
					{
						const auto& [name, number] = *version;
						std::wcout << name << "_";
						std::cout << number << std::endl;
					}
					else if( level == Warn::All )
					{
						std::cout << "Could not find product or version info for " << arg << std::endl;
					}
					break;
				}
				case SearchMode::Either:
				{
					const auto version = GetDllInfoFromVersionInfo( arg );
					if( version.has_value() )
					{
						const auto& [name, number] = *version;
						std::wcout << name << "_";
						std::cout << number << std::endl;
					}
					else if( level == Warn::All )
					{
						std::cout << GetDllInfoFromFile( arg ).value_or( "Could not find product or version info for " + arg ) << std::endl;
					}
					break;
				}
				default:
				{
					std::cout << "unkown argument" << std::endl;
				}
			}
		}
		else if( arg != "-f" && arg != "-p" && arg != "-a" )
		{
			if( level == Warn::All )
			{
				std::cout << arg << " not found" << std::endl;
			}
		}
	}
	return 0;
}
