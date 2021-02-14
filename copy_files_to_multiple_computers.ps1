$computers= get-content "f:\computers-test.txt"

$file = "W:\Resrc\Script\Dev\Harmony_Resources\new_INSTALLS\15_0_6_14034\Toon Boom Harmony 15.0 lke"

$destination = "\c$\Program Files (x86)\Toon Boom Animation\Toon Boom Harmony 15.0 lke"

foreach ($computer in $computers) {

    if ((Test-Path -Path \\$computer\$destination)) {

        Copy-Item $file -Destination \\$computer\$destination -Recurse
        #Invoke-Command -computername wds-server -filepath c:\edit.ps1

    } else {

      "\\$computer\$destination is not reachable or does not exist"

}

}