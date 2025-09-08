#(@(& 'C:/Users/aryah.kannan/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init powershell --config='' --print) -join "`n") | Invoke-Expression

function Invoke-Starship-PreCommand {
    $prompt = (pwd).Path.Replace("$home\Projects", "")
    $host.ui.RawUI.WindowTitle = "$prompt"
}

Invoke-Expression (& starship init powershell)
Set-PSReadLineOption -PredictionViewStyle ListView
$projectHome = "$home\Projects";

Import-Module $projectHome/bin/utils.psm1 -DisableNameChecking

set-alias vim nvim
set-alias cwd copy-working-dir
set-alias lz lazygit
set-alias cn cn-get-commands
set-alias ph project-home
set-alias or open-repo
set-alias op open-project
set-alias oc open-code
set-alias gh go-home
set-alias qr quiet-rm
set-alias cc cmake-clean
set-alias sf search-files
set-alias pj pretty-json
set-alias bp build-project

function yz {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
    set-cursor-style -Style reset
}
$nvimconfig = "$env:LOCALAPPDATA\nvim\init.lua";
#$conanData = conan config get storage.path;
$env:CDT_VENV_HOME="C:\Users\aryah.kannan\Projects\virtual_environments"
$env:YAZI_FILE_ONE="C:\Users\aryah.kannan\AppData\Local\Programs\Git\usr\bin\file.exe"
$env:STARSHIP_CONFIG="C:\Users\aryah.kannan\.config\starship.toml"
$env:CONAN_USE_ALWAYS_SHORT_PATHS="True"
$env:CASTLE_CACHE="C:\Users\aryah.kannan\Projects\"
$env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\x64\bin\clang.exe"
Import-Module $projectHome/bin/zoxide_init.psm1 -DisableNameChecking
Import-Module $projectHome/bin/castle-completions.psm1 -DisableNameChecking
