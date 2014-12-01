IMAGE_DIRECTORY_ENTRY_RELOC_TABLE       equ    0a0h     ;offset from beginning of NT_HEADERS
IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY   equ    0a8h     ;offset from beginning of NT_HEADERS
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG_TABLE equ    0c8h     ;offset from beginning of NT_HEADERS

MAX_LEVELS                              equ    257

kernel32 struct
    kUnmapViewOfFile      dd ?
    kSetFileAttributesW   dd ?
    kSetCurrentDirectoryW dd ?
    kMapViewOfFile        dd ?
    kGlobalFree           dd ?
    kGlobalAlloc          dd ?
    kFindNextFileW        dd ?
    kFindFirstFileW       dd ?
    kFindClose            dd ?
    kCreateFileW          dd ?
    kCreateFileMappingW   dd ?
    kCloseHandle          dd ?
kernel32 ends

level_data struct
    findhandler dd ?
level_data ends 

regmap struct
    regEdi  dd ?
    regEsi  dd ?
    regEbp  dd ?
    regEsp  dd ?
    regEbx  dd ?
    regEdx  dd ?
    regEcx  dd ?
    regEax  dd ?
regmap ends

LIST_ENTRY struct
    FLink  dd ?
    BLink  dd ?
LIST_ENTRY ends

_PEB_LDR_DATA struct
    dwLength                           dd ?
    bInitialized                       dd ?
    dwSsHandle                         dd ?
    dwInLoadOrderModuleList            LIST_ENTRY <?>
    dwInMemoryOrderModuleList          LIST_ENTRY <?>
    dwInInitializationOrderModuleList  LIST_ENTRY <?>
_PEB_LDR_DATA ends

PROCESS_ENVIRONMENT_BLOCK struct
	bInhiritedAddressSpace     db ?
	bReadImageFileExecOptions  db ?
	bBeingDebugged             db ?
	bSpare                     db ?
	hMutant                    dd ?
	dwImageBaseAddress         dd ?
	lpLoaderData               dd ?
	lpProcessParameters        dd ?
PROCESS_ENVIRONMENT_BLOCK ends

WIN32_FIND_DATA struct
    dwFileAttributes dd ?
    ftCreationTime   dq ?
    ftLastAccessTime dq ?
    ftLastWriteTime  dq ?
    nFileSizeHigh    dd ?
    nFileSizeLow     dd ?
    dwReserved0      dd ?
    dwReserved1      dd ?
    cFileName        db 260 dup (?)
    cAlternate       db 0eh dup (?)
WIN32_FIND_DATA ends