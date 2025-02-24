# Used to determine whether compiler is able to compile and/or run a
# given snippet of source.  Useful for compiler bug workarounds and
# unsupported features.

macro (check_fortran_compile file var)

  if (NOT CMAKE_REQUIRED_QUIET)
    message (STATUS "Performing Test ${var}")
  endif ()

if (${ARGN})
  try_compile (
    ${var}
    ${CMAKE_BINARY_DIR}
    ${file}
    CMAKE_FLAGS "-DCOMPILE_DEFINITIONS:STRING=${MPI_Fortran_Flags}"
    "-DINCLUDE_DIRECTORIES:LIST=${MPI_Fortran_INCLUDE_PATH}"
    "-DLINK_LIBRARIES:LIST=${MPI_Fortran_LIBRARIES}"
    )
else ()
  try_compile (
    ${var}
    ${CMAKE_BINARY_DIR}
    ${file}
    )
endif ()

  if (${var})
    if (NOT CMAKE_REQUIRED_QUIET)
      message(STATUS "Performing Test ${var}: SUCCESSS")
    endif ()

    add_definitions(-D${var})

  else ()

    if (NOT CMAKE_REQUIRED_QUIET)
      message(STATUS "Performing Test ${var}: FAILURE")
    endif ()

  endif ()

endmacro (check_fortran_compile)


macro (check_fortran_compile_and_run file var)

  if (NOT CMAKE_REQUIRED_QUIET)
    message (STATUS "Performing Test ${var}")
  endif ()

  try_run (
    code_runs
    code_compiles
    ${CMAKE_BINARY_DIR}
    ${file}
    )

  if (${code_compiles})
    if (${code_runs} EQUAL 0)

      if (NOT CMAKE_REQUIRED_QUIET)
	message (STATUS "Performing Test ${var}: SUCCESS")
      endif ()

      add_definitions(-D${var})

      set (${var} 1)

    else ()

      if (NOT CMAKE_REQUIRED_QUIET)
	message (STATUS "Performing Test ${var}: RUN FAILURE")
      endif ()

    endif ()

  else ()

      if (NOT CMAKE_REQUIRED_QUIET)
	message (STATUS "Performing Test ${var}: BUILD FAILURE")
      endif ()

  endif()

endmacro (check_fortran_compile_and_run)
