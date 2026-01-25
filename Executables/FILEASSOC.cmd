
@REM copy /y "Associations.dll" "%WINDIR%\System32\OEMDefaultAssociations.dll"
copy /y "OEMDefaultAssociations.xml" "%WINDIR%\System32\OEMDefaultAssociations.xml"

@echo OFF
for /f "usebackq tokens=2 delims=\" %%A in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	REM If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs don't have this key.
	reg query "HKU\%%A" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > NUL 2>&1
		if not errorlevel 1 (
			PowerShell -NoP -ExecutionPolicy Bypass -File assoc.ps1 "Placeholder" "%%A" ".bmp:PhotoViewer.FileAssoc.Bitmap" ".dib:PhotoViewer.FileAssoc.Bitmap" ".jfif:PhotoViewer.FileAssoc.JFIF" ".jpe:PhotoViewer.FileAssoc.Jpeg" ".jpeg:PhotoViewer.FileAssoc.Jpeg" ".jpg:PhotoViewer.FileAssoc.Jpeg" ".jxr:PhotoViewer.FileAssoc.Wdp" ".png:PhotoViewer.FileAssoc.Png" ".tif:PhotoViewer.FileAssoc.Tiff" ".tiff:PhotoViewer.FileAssoc.Tiff" ".wdp:PhotoViewer.FileAssoc.Wdp" ".7z:7-Zip.7z" ".zip:7-Zip.zip" ".rar:7-Zip.rar" ".tar:7-Zip.tar" ".gz:7-Zip.gz" ".bz2:7-Zip.bz2" ".xz:7-Zip.xz" ".7z:PeaZip.7z" ".zip:PeaZip.zip" ".rar:PeaZip.rar" ".tar:PeaZip.tar" ".gz:PeaZip.gz" ".bz2:PeaZip.bz2" ".xz:PeaZip.xz" ".mp4:VLC.mp4" ".avi:VLC.avi" ".mkv:VLC.mkv" ".mp3:VLC.mp3" ".flac:VLC.flac" ".wav:VLC.wav" ".mp4:MPC-HC.mp4" ".avi:MPC-HC.avi" ".mkv:MPC-HC.mkv" ".mp3:MPC-HC.mp3" ".flac:MPC-HC.flac" ".wav:MPC-HC.wav" ".mp4:PotPlayerMini64.mp4" ".avi:PotPlayerMini64.avi" ".mkv:PotPlayerMini64.mkv" ".mp3:PotPlayerMini64.mp3" ".flac:PotPlayerMini64.flac" ".wav:PotPlayerMini64.wav"
	)
)
