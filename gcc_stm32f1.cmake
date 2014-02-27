SET(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
SET(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m3" CACHE INTERNAL "asm compiler flags")

SET(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -Wl,--gc-sections -mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "shared linker flags")

SET(STM32_CHIP_TYPES CL HD HD_VL MD MD_VL LD LD_VL XL CACHE INTERNAL "stm32f1 chip types")
SET(STM32_CODES "10[57]" "10[13].[CDE]" "100.[CDE]" "10[123].[8B]" "100.[8B]" "10[123].[46]" "100.[46]" "10[13].[FG]")

MACRO(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF](10[012357].[468BCDE]).+$" "\\1" STM32_CODE ${CHIP})
    SET(INDEX 0)
    FOREACH(C_TYPE ${STM32_CHIP_TYPES})
        LIST(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        IF(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            SET(RESULT_TYPE ${C_TYPE})
        ENDIF()
        MATH(EXPR INDEX "${INDEX}+1")
    ENDFOREACH()
    SET(${CHIP_TYPE} ${RESULT_TYPE})
ENDMACRO()

MACRO(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF](10[012357]).[468BCDE]" "\\1" STM32_CODE ${CHIP})
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF]10[012357].([468BCDE])" "\\1" STM32_SIZE_CODE ${CHIP})
    
    IF(STM32_SIZE_CODE STREQUAL "4")
        SET(FLASH "16K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "6")
        SET(FLASH "32K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "8")
        SET(FLASH "64K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "B")
        SET(FLASH "128K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "C")
        SET(FLASH "256K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "D")
        SET(FLASH "384K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "E")
        SET(FLASH "512K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "F")
        SET(FLASH "768K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "G")
        SET(FLASH "1024K")
    ENDIF()
    
    STM32_GET_CHIP_TYPE(${CHIP} TYPE)
    
    IF(${TYPE} STREQUAL "XL")
        SET(RAM "80K")
    ELSEIF(${TYPE} STREQUAL "CL")
        SET(RAM "64K")
    ELSEIF((${TYPE} STREQUAL "LD") AND ((STM32_CODE STREQUAL "102") OR (STM32_CODE STREQUAL "101")))
        IF(STM32_SIZE_CODE STREQUAL "4")
            SET(RAM "4K")
        ELSE()
            SET(RAM "6K")
        ENDIF()
    ELSEIF(${TYPE} STREQUAL "LD")
        IF(STM32_SIZE_CODE STREQUAL "4")
            SET(RAM "6K")
        ELSE()
            SET(RAM "10K")
        ENDIF()
    ELSEIF(${TYPE} STREQUAL "LD_VL")
        SET(RAM "4K")
    ELSEIF((${TYPE} STREQUAL "MD") AND ((STM32_CODE STREQUAL "102") OR (STM32_CODE STREQUAL "101")))
        IF(STM32_SIZE_CODE STREQUAL "8")
            SET(RAM "10K")
        ELSE()
            SET(RAM "16K")
        ENDIF()
    ELSEIF(${TYPE} STREQUAL "MD")
        SET(RAM "20K")
    ELSEIF(${TYPE} STREQUAL "MD_VL")
        SET(RAM "8K")
    ELSEIF((${TYPE} STREQUAL "HD") AND (STM32_CODE STREQUAL "101"))
        IF(STM32_SIZE_CODE STREQUAL "C")
            SET(RAM "32K")
        ELSE()
            SET(RAM "48K")
        ENDIF()
    ELSEIF(${TYPE} STREQUAL "HD")
        IF(STM32_SIZE_CODE STREQUAL "C")
            SET(RAM "48K")
        ELSE()
            SET(RAM "64K")
        ENDIF()
    ELSEIF(${TYPE} STREQUAL "HD_VL")
        IF(STM32_SIZE_CODE STREQUAL "C")
            SET(RAM "24K")
        ELSE()
            SET(RAM "32K")
        ENDIF()
    ENDIF()
    
    SET(${FLASH_SIZE} ${FLASH})
    SET(${RAM_SIZE} ${RAM})
ENDMACRO()

FUNCTION(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F1 chip type: ${CHIP_TYPE}")
    ENDIF()
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "STM32F1;STM32F10X_${CHIP_TYPE}")
ENDFUNCTION()