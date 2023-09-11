$root_folder = Invoke-Expression "git rev-parse --show-toplevel"
echo "Root folder is: $root_folder"

function Install-Config ($folder) {
	New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA/$folder" -Value "$root_folder/$folder"
}

Install-Config "nvim"
