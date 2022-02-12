Import-Csv urls.csv -Header Source, Destination | Start-BitsTransfer -ErrorAction Stop

$BadFiles = ((Get-AuthenticodeSignature dvd\*.exe) + (Get-AuthenticodeSignature dvd\*.msu) | where Status -ne "Valid")
if ($BadFiles) {
    $BadFiles
    cmd.exe /c pause
    Exit
}

$FSI = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
$FSI.FreeMediaBlocks = 0
$FSI.FileSystemsToCreate = 4
$FSI.UDFRevision = 0x201
$FSI.VolumeName = "WIN7PATCH"
$FSI.Root.AddTree((Join-Path -Path (Get-Location) -ChildPath "dvd"), $False)

$ResultImage = $FSI.CreateResultImage()

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using IStream = System.Runtime.InteropServices.ComTypes.IStream;
public class IStreamSaver {
    [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
    static internal extern int SHCreateStreamOnFile(string pszFile, uint grfMode, out IStream ppstm);
    
    public static void SaveStream(string imagePath, object imageStream) {
        IStream fileStream;
        int hr = SHCreateStreamOnFile(imagePath, 0x00001001, out fileStream);
        if (hr != 0) {
            System.Runtime.InteropServices.Marshal.ThrowExceptionForHR(hr);
        }
        (imageStream as IStream).CopyTo(fileStream, -1, IntPtr.Zero, IntPtr.Zero);
        System.Runtime.InteropServices.Marshal.ReleaseComObject(fileStream);
    }
}
'@

[IStreamSaver]::SaveStream((Join-Path -Path (Get-Location) -ChildPath "win7patch.iso"), $ResultImage.ImageStream)

Get-ChildItem win7patch.iso
cmd.exe /c pause
Exit
