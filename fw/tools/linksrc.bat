rem XSCT gives no way to link external source files into a project, only to copy them.
rem This Windows-only script gives `make` a way to create a shortcut to the source folder
mklink /D %1 %2
exit 0