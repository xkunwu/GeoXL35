## macro for listing public include directories
MACRO( LIST_INCS DEST_FILE SORC_PATH )
	STRING( REGEX REPLACE "\\\\" "/" DEST_FILE ${DEST_FILE} )
	STRING( REGEX REPLACE "\\\\" "/" SORC_PATH ${SORC_PATH} )
	SET( FILE_NAME ${DEST_FILE} )
	
	FILE( WRITE ${FILE_NAME} "## never edit this file manually (generated by script)\n" )
	
	FILE( GLOB_RECURSE path_list ${SORC_PATH}/*.h )
    SET( dir_list "" )
    FOREACH( file_path ${path_list} )
        GET_FILENAME_COMPONENT( dir_path ${file_path} PATH )
        SET( dir_list ${dir_list} ${dir_path} )
    ENDFOREACH()
    LIST( REMOVE_DUPLICATES dir_list )
	
	FOREACH(ecname ${ARGN})
		SET( tmp_list "" )
		FOREACH(sorcname ${dir_list})
			STRING(FIND "${sorcname}" "${ecname}" EC_Pos)
            IF (${EC_Pos} EQUAL -1)
                SET( tmp_list ${tmp_list} ${sorcname} )
            ENDIF ()
		ENDFOREACH()
		SET (dir_list ${tmp_list})
	ENDFOREACH()
	
    FOREACH( dir_path ${dir_list} )
		FILE( APPEND ${FILE_NAME} "${dir_path}\n" )
    ENDFOREACH()

ENDMACRO( LIST_INCS )

## macro for listing source directories
MACRO( LIST_SRCS DEST_PATH SORC_PATH )
    STRING( REGEX REPLACE "\\\\" "/" DEST_PATH ${DEST_PATH} )
    STRING( REGEX REPLACE "\\\\" "/" SORC_PATH ${SORC_PATH} )

    FILE( GLOB_RECURSE FILE_LIST
        RELATIVE ${SORC_PATH}
        "${SORC_PATH}/*.cpp"
        "${SORC_PATH}/*.hpp"
        "${SORC_PATH}/*.c"
        "${SORC_PATH}/*.h"
        "${SORC_PATH}/*.cu"
        "${SORC_PATH}/*.ui"
        "${SORC_PATH}/*.qrc"
        )

	FOREACH(ecname ${ARGN})
		SET( tmp_list "" )
		FOREACH(sorcname ${FILE_LIST})
			STRING(FIND "${sorcname}" "${ecname}" EC_Pos)
            IF (${EC_Pos} EQUAL -1)
                SET( tmp_list ${tmp_list} ${sorcname} )
            ENDIF ()
		ENDFOREACH()
		SET (FILE_LIST ${tmp_list})
	ENDFOREACH()

    FOREACH( currfile ${FILE_LIST} )
        SET( folder ${currfile} )
        #FILE( RELATIVE_PATH folder ${SORC_PATH} ${currfile} )
        GET_FILENAME_COMPONENT( filename ${folder} NAME )
        STRING( REPLACE ${filename} "" folder ${folder} )
        IF( NOT folder STREQUAL "" )
            STRING( REGEX REPLACE "/+$" "" folderlast ${folder} )
            STRING( REPLACE "/" "\\" folderlast ${folderlast} )
            SOURCE_GROUP( "${folderlast}" FILES "${currfile}" )
        ENDIF( NOT folder STREQUAL "" )
    ENDFOREACH( currfile ${FILE_LIST} )

ENDMACRO( LIST_SRCS )

## macro for seperate file types
MACRO( SEPE_LIST )

    FOREACH( currfile ${FILE_LIST} )
        #GET_FILENAME_COMPONENT( fileext ${currfile} EXT ) # match to the 1st period
        STRING(REGEX REPLACE "^.+(\\.[^.]+)$" "\\1" fileext ${currfile})
        IF( fileext STREQUAL ".c" OR fileext STREQUAL ".cpp" OR fileext STREQUAL "cu" )
            SET( prj_srcs ${prj_srcs} ${currfile} )
        ELSEIF( fileext STREQUAL ".h" OR fileext STREQUAL ".hpp" )
            SET( prj_incs ${prj_incs} ${currfile} )
        ELSEIF( fileext STREQUAL ".ui" )
            SET( uic_srcs_tmp ${uic_srcs_tmp} ${currfile} )
        ELSEIF( fileext STREQUAL ".qrc" )
            SET( rcc_incs_tmp ${rcc_incs_tmp} ${currfile} )
        ENDIF()
    ENDFOREACH( currfile ${FILE_LIST} )

    QT_WRAP_UI_MOD(uic_srcs ${uic_srcs_tmp})
    QT_ADD_RESOURCES_MOD(rcc_incs ${rcc_incs_tmp})

ENDMACRO( SEPE_LIST )

## macro for listing moc includes
MACRO( LIST_MOCS DEST_PATH SORC_PATH )
    STRING( REGEX REPLACE "\\\\" "/" DEST_PATH ${DEST_PATH} )
    STRING( REGEX REPLACE "\\\\" "/" SORC_PATH ${SORC_PATH} )

    SET(Q_OBJECT_Pos)
    FOREACH(hfile ${prj_incs})
        FILE(READ "${hfile}" hfile_content)
        STRING(FIND "${hfile_content}" "Q_OBJECT" Q_OBJECT_Pos)
        IF (NOT (${Q_OBJECT_Pos} EQUAL -1))
            QT_WRAP_CPP_MOD(moc_incs ${hfile})
        ENDIF ()
    ENDFOREACH(hfile)

ENDMACRO( LIST_MOCS )

## macro for listing files
MACRO( LIST_FILE DEST_PATH SORC_PATH )
    SET( prj_incs "" )
    SET( prj_srcs "" )
    SET( uic_srcs "" )
    SET( extra_uic_srcs "" )
    SET( rcc_incs "" )
    SET( moc_incs "" )
    SET( extra_moc_incs "" )

    if(${ARGC} GREATER 2)
        LIST_SRCS( ${DEST_PATH} ${SORC_PATH} ${ARGN} )
    else(${ARGC} GREATER 2)
        LIST_SRCS( ${DEST_PATH} ${SORC_PATH} )
    endif(${ARGC} GREATER 2)

    SEPE_LIST( )
    LIST_MOCS( ${DEST_PATH} ${SORC_PATH} )

    STRING( REGEX REPLACE "\\\\" "/" DEST_PATH ${DEST_PATH} )
    SET( FILE_NAME ${DEST_PATH}/srcs_list )

    FILE( WRITE ${FILE_NAME} "## never edit this file manually (generated by script)\n" )
    FILE( APPEND ${FILE_NAME} "prj_srcs(\n" )
    FOREACH( fname ${prj_srcs} )
        FILE( APPEND ${FILE_NAME} "\t${fname}\n" )
    ENDFOREACH()
    FILE( APPEND ${FILE_NAME} "\t)\n" )
    FILE( APPEND ${FILE_NAME} "prj_incs(\n" )
    FOREACH( fname ${prj_incs} )
        FILE( APPEND ${FILE_NAME} "\t${fname}\n" )
    ENDFOREACH()
    FILE( APPEND ${FILE_NAME} "\t)\n" )
    FILE( APPEND ${FILE_NAME} "uic_srcs(\n" )
    FOREACH( fname ${uic_srcs} )
        FILE( APPEND ${FILE_NAME} "\t${fname}\n" )
    ENDFOREACH()
    FILE( APPEND ${FILE_NAME} "\t)\n" )
    FILE( APPEND ${FILE_NAME} "rcc_incs(\n" )
    FOREACH( fname ${rcc_incs} )
        FILE( APPEND ${FILE_NAME} "\t${fname}\n" )
    ENDFOREACH()
    FILE( APPEND ${FILE_NAME} "\t)\n" )
    FILE( APPEND ${FILE_NAME} "moc_incs(\n" )
    FOREACH( fname ${moc_incs} )
        FILE( APPEND ${FILE_NAME} "\t${fname}\n" )
    ENDFOREACH()
    FILE( APPEND ${FILE_NAME} "\t)\n" )

ENDMACRO( LIST_FILE )

