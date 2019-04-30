$destination = "C:\TEST\temp.jpeg"
$Format = [system.Drawing.Imaging.ImageFormat]::Jpeg

$image  = Get-Clipboard -Format Image
        $image.Save($destination, $Format)