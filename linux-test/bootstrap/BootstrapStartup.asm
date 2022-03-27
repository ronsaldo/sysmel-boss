SECTION .text
GLOBAL BootstrapEnvironment.RunStartupScript
BootstrapEnvironment.RunStartupScript:
    ret

SECTION .data
GLOBAL BootstrapEnvironment.StartupScript
BootstrapEnvironment.StartupScript:

INCBIN "StartupScript.sysmel"
GLOBAL BootstrapEnvironment.StartupScriptSize
BootstrapEnvironment.StartupScriptSize equ $ - BootstrapEnvironment.StartupScript
