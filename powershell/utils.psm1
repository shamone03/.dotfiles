
enum CursorStyle
{
    reset = 0
    block_blink = 1
    block = 2
    underline_blink = 3
    underline = 4
    bar_blink = 5
    bar = 6
}

function set-cursor-style {
    param (
        # style
        [Parameter(Mandatory)]
        [CursorStyle]$Style
    )
    Write-Output "`e[$([int]$Style) q"
}

function open-code {
    $gitHome = get-project-home
	if ($gitHome -ne "") {
        if (test-path $gitHome/.vscode) {
            code $gitHome
        } else {
        	cp $projectHome/vscode-settings/.vscode $gitHome/ -Recurse -Force
    		code $gitHome
        }
	}
}

function get-aims-latest {
    param(
        [String]$outfile = "AIMS_Latest.zip"
    )
    if (test-path $outfile) {
        rm $outfile -recurse -force
    }
    Invoke-WebRequest "http://cn-appaf-p01.ad.onepal.com:8081/artifactory/aims-builds-daily/All/AIMS_Latest.zip" -OutFile $outfile

    $outdir = "$projectHome/$((Get-Item $outfile).BaseName)"
    Expand-Archive $outfile -DestinationPath $outdir -Force
    
    rm $outfile -force

	[console]::beep(2000, 500)
}

function get-vscode-settings {
    cp $projectHome/vscode-settings/.vscode . -Recurse -Force
}

function build-project {
	param (
		[ValidateSet('Release', 'Debug')]
		[String]$config = 'Debug',
		[switch]$rebuild,
		[ValidateSet('default', 'code')]
		[String]$open = 'code',
		[String]$output = 'build/msvc17',
        [String]$sources = 'sources',
		[switch]$remote,
		[switch]$install,
		[String]$conanfile = "conanfile.py"
    )
   	$sw = [Diagnostics.Stopwatch]::New()
	$sw.Start()
	$conan = { conan install $conanfile -if $output -pr "$(($config -eq 'Debug') ? 'x64d' : 'x64')" -b missing -g cmake_multi }
	if ($remote) {
		$conan = { conan install $conanfile -if $output -pr "$(($config -eq 'Debug') ? 'x64d' : 'x64')" -b missing -g cmake_multi -u }
	}

	if ($rebuild) {
		git clean -xdf -e Cargo.lock -e .vscode -e sources
	}
    if ($? -eq $false) {
        echo "Failed to git clean files"
        return
    }

	if ($install) {
		& $conan
	}
    echo $?
    if ($? -eq $false) {
        echo "Failed to conan install"
        return
    }

	$build = { cmake -S"$sources" -B"$output" -DCMAKE_BUILD_TYPE="$config" -G"Visual Studio 17 2022" && cmake --build "$output" --parallel --config "$config" }
	& $build

    if ($? -eq $False) {
        echo "Failed to build project"
        return
    }
	
	$sw.Stop()
    $sw.Elapsed | ft
	if ($open -eq 'code') {
        get-vscode-settings
		code .
	} else {
		cmake --open "$output"
	}
	[console]::beep(2000, 500)
}

function pretty-json {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

function cn-version() {
	conan inspect . -a version
}

function get-project-home() {
    $gitHome = git rev-parse --show-toplevel 2>$null | out-string
    if ($LASTEXITCODE -eq 0) {
    	return $gitHome.TrimEnd()
    } else {
        Write-Host "Not a git repository" -ForegroundColor Red
		return ""
    }
}

function project-home() {
    $gitHome = get-project-home
    if ($gitHome -ne "") {
        cd $gitHome
    }
}

function go-home() {
	cd $projectHome
}

function open-project() {
	cmake --open "build/msvc17"
}

function watch-copy($file, $dest) {
	watch-file -file $file -action { cp $file $dest }
}

function open-repo() {
	Param(	
		[Parameter(Mandatory = $false)]
		[switch]$pr
	)
	$link = ((git config --get remote.origin.url) | out-string).Trim();

	if($pr) {
		$link = $link + "/pullrequests?_a=mine"
	}

	start $link 
}

function watch {
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[String]$action,

		[Parameter(Mandatory = $false, Position = 1)]
		[int]$interval = 1

	)

	$block = [ScriptBlock]::Create($action);
	while ($true) {
		cls;
		& $block;
		sleep $interval;
	}

}

function watch-file($file, $action) {
	$activity = "Watching $file"
	if ((get-item $file).exists -eq $true) {
		& $action
		$lastWriteTime = (get-item $file).lastwritetime.ticks
	} else {
		$status = "waiting for file change"
	}

	while ($true) {
		$status = ""

		if ((get-item $file).exists -eq $true) {
			if ($lastWriteTime -lt (get-item $file).lastwritetime.ticks) {
				& $action
				$lastWriteTime = (get-item $file).lastwritetime.ticks
				echo "$file changed"
				continue;
			} else {
				$status = "waiting for file change"
			}
		} else {
			$status = "$file doesn't exist"
		}
		write-progress -Activity $activity -Status $status
		start-sleep -milliseconds 500
	}
}

function quiet-rm($item) {
    if (Test-Path $item) {
        rm -r -force $item
        echo "Removed $item "
    } else {
        echo "$item does not exist"
    }
}

function cmake-clean() {
    qr CMakeUserPresets.json
    qr "./build/*"
}

function cn-get-commands {
 
	param (
		[Parameter(Mandatory = $true)]
		[ValidateSet('cmake', 'cache', 'create', 'ignore', 'release', 'install', 'installcache')]
		[String]$option,
		[Parameter(Mandatory = $false)]
		[switch]$remove,
		[Parameter(Mandatory = $false)]
		[switch]$open
	)

	$cmake = { cdt cmake setup -p . -pr x64d -u && cmake --build build/msvc17 --parallel }
	$cmakerelease = { cdt cmake setup -p . -pr x64 -u && cmake --build build/msvc17 --parallel --config Release && start .\build\msvc17\Release }
    $cmakecache = { cdt cmake setup -p . -pr x64d && cmake --build build/msvc17 --parallel }
    $install = { conan install . -if .conan -pr x64d -u -b=missing }
    $installcache = { conan install . -if .conan -pr x64d -b=missing }
    $create = { conan create . cn/staging -pr x64d -b=missing }
    $createignore = { conan create . cn/staging -pr x64d -b=missing --ignore-dirty } 
 
	if ($option) {
		echo $option
    	$sw = [Diagnostics.Stopwatch]::New()
		switch ($option) {
			'cmake' { $sw.start() && echo $cmake.ToString() && & $cmake && & { if($open) { cmake --open build/msvc17 } else { echo "success" } }; }
			'cache' { $sw.start() && echo $cmakecache.ToString() && & $cmakecache && & { if($open) { cmake --open build/msvc17 } else { echo "success" } }; }
			'release' { $sw.start() && echo $cmakerelease.ToString() && & $cmakerelease; }
			'install' { $sw.start() && echo $install.ToString() && & $install; }
			'installcache' { $sw.start() && echo $installcache.ToString() && & $installcache; }
			'create' { $sw.start() && echo $create.ToString() && & { if($remove) { conan-remove (get-item .).name } } && & $create; }
			'ignore' { $sw.start() && echo $createignore.ToString() && & { if($remove) { conan-remove (get-item .).name } } && & $createignore; }
			default { echo "Invalid Option" }
		}
	    $sw.Stop()
    	$sw.Elapsed | ft
		return;
	} else {
		echo "Choose An Option"
	}
    $sw.Stop()
    $sw.Elapsed | ft
}

function copy-working-dir() {
	echo "Copied: "
	pwd
	pwd | scb
}

function cn-create() {
	$start = (gi .).fullname;
	cd $projectHome;
	foreach ($package in $args) {
		if (test-path $package) {
			cd $package;
			cn ignore;
			cd ..
		}
	}
	cd $start;
}

function conan-remove() {
    foreach ($package in $args) {
        if (($package -ne "*") -and ($package -ne "")) {
            echo "Removing $package from cache"
			iex "conan remove $package -f" 
        } else {
            echo "NO"
        }
    }
}

function conan-open() {
    foreach($package in $args) {
        if (test-path ((conan config get storage.path) + "\" + $package)) {
            start $package -WorkingDirectory $(conan config get storage.path)
        } else {
            echo "$package not installed"            
        }
    }
}

function search-files([string[]] $exts, $term) {
    $filenames = @()
    foreach ($name in $exts) {
        $filenames += "*.$name"
    }

    dir -i $filenames -r | sls -pattern $term
}
