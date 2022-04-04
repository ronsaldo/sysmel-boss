SECTION .text

GLOBAL BootstrapEnvironment.Initialize
BootstrapEnvironment.Initialize:
    buildGCStackFrame 0, 0

    call ObjectModel.BuildImageRootObject

    destroyGCStackFrame
    ret
