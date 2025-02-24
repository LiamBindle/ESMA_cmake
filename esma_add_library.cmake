# In most cases, GEOS follows a standard process to configure each
# component within the nested hierarchy.  The algorithm below codifies
# this standard process, thereby consiberably simplifying most
# CMakeLists.txt files in the code.

# Eventually the name of subcomponents and subdirectories will coincide.
# Waiting for git so that the rename is easy.


macro (esma_add_library this)

  if (CMAKE_DEBUG)
    message (STATUS "Generating build instructions for component: ${this}")
  endif ()

  set (options OPTIONAL EXCLUDE_FROM_ALL)
  set (multiValueArgs SRCS SUBCOMPONENTS SUBDIRS DEPENDENCIES INCLUDES NEVER_STUB)
  cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Subdirs must exist and should be configured prior to subcomponents.
  foreach (subdir ${ARGS_SUBDIRS})
    add_subdirectory(${subdir})
  endforeach()

  # Configure subcomponents.  These can be stubbed and may have a
  # different name than the directory they reside in.  (Most
  # unfortunate.)
  set (non_stubbed)
  foreach (subdir ${ARGS_SUBCOMPONENTS})

    string (SUBSTRING ${subdir} 0 1 leading_character)
    if (leading_character STREQUAL "@")
      string (SUBSTRING ${subdir} 1 -1 mod_name) # strip leading "@"
    else ()
      set (mod_name ${subdir})
    endif()

    if (NOT rename_${subdir}) # usual case
      set (module_name ${mod_name})
    else ()
      set(module_name ${rename_${mod_name}})
    endif ()

    if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${subdir})
      add_subdirectory (${subdir})
      list (APPEND non_stubbed ${mod_name})
    else () # make stub and append to srcs (in ARGS_SRCS)
      if (CMAKE_DEBUG)
	message (STATUS  "  ... Creating stub component ${module_name}")
      endif()
      esma_create_stub_component (ARGS_SRCS ${module_name})
    endif ()

  endforeach ()

  ecbuild_add_library (TARGET ${this}
    SOURCES ${ARGS_SRCS}
    LIBS ${ARGS_DEPENDENCIES}
    INCLUDES ${ARGS_INCLUDES}
    )

  set_target_properties(${this} PROPERTIES EXCLUDE_FROM_ALL ${ARGS_EXCLUDE_FROM_ALL})
  set_target_properties (${this} PROPERTIES Fortran_MODULE_DIRECTORY ${esma_include}/${this})

  set (install_dir include/${this})
  # Export target  include directories for other targets
  target_include_directories(${this} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}> # stubs
# modules and copied *.h, *.inc    
    $<BUILD_INTERFACE:${esma_include}/${this}>
    $<INSTALL_INTERFACE:${install_dir}>
    ) 

  # This library depends on all DEPENDENCIES and _non-stubbed_ subcomponents.
  set (all_dependencies ${ARGS_DEPENDENCIES} ${non_stubbed})
  if (all_dependencies)
    target_link_libraries(${this} PUBLIC ${all_dependencies})
  endif ()
  
  if (ARGS_INCLUDES)
    target_include_directories(${this} PUBLIC $<BUILD_INTERFACE:${ARGS_INCLUDES}>)
  endif ()

  # The following possibly duplicates logic that is already in the ecbuild layer
  install (DIRECTORY  ${esma_include}/${this}/ DESTINATION include/${this})

endmacro ()
