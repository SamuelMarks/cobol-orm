/**
 * @file cobol_orm_export.h
 * @brief Symbol export macros, no-discard attributes, and strict ISO C89
 * fixed-width integer typedefs for cobol-orm.
 */

#ifndef COBOL_ORM_EXPORT_H
/** @brief Header guard for cobol_orm_export.h. */
#define COBOL_ORM_EXPORT_H

/* clang-format off */
#include <stddef.h>
#if defined(_MSC_VER) && _MSC_VER < 1600
typedef signed __int8 cobol_orm_i8_t;
typedef unsigned __int8 cobol_orm_u8_t;
typedef signed __int16 cobol_orm_i16_t;
typedef unsigned __int16 cobol_orm_u16_t;
typedef signed __int32 cobol_orm_i32_t;
typedef unsigned __int32 cobol_orm_u32_t;
typedef signed __int64 cobol_orm_i64_t;
typedef unsigned __int64 cobol_orm_u64_t;
#else
#include <stdint.h>
/** @brief Signed 8-bit integer type. */
typedef int8_t cobol_orm_i8_t;
/** @brief Unsigned 8-bit integer type. */
typedef uint8_t cobol_orm_u8_t;
/** @brief Signed 16-bit integer type. */
typedef int16_t cobol_orm_i16_t;
/** @brief Unsigned 16-bit integer type. */
typedef uint16_t cobol_orm_u16_t;
/** @brief Signed 32-bit integer type. */
typedef int32_t cobol_orm_i32_t;
/** @brief Unsigned 32-bit integer type. */
typedef uint32_t cobol_orm_u32_t;
/** @brief Signed 64-bit integer type. */
typedef int64_t cobol_orm_i64_t;
/** @brief Unsigned 64-bit integer type. */
typedef uint64_t cobol_orm_u64_t;
#endif
/* clang-format on */

/** @brief Shared library export/import visibility qualifier. */
#ifndef COBOL_ORM_EXPORT
#if defined(_WIN32) || defined(__CYGWIN__)
#if defined(COBOL_ORM_SHARED)
#if defined(cobol_orm_c_EXPORTS)
#define COBOL_ORM_EXPORT __declspec(dllexport)
#else
#define COBOL_ORM_EXPORT __declspec(dllimport)
#endif
#else
#define COBOL_ORM_EXPORT
#endif
#else
#if defined(__GNUC__) && __GNUC__ >= 4
#define COBOL_ORM_EXPORT __attribute__((visibility("default")))
#else
#define COBOL_ORM_EXPORT
#endif
#endif
#endif

/** @brief Compiler attribute enforcing callers inspect returned error enums. */
#ifndef COBOL_ORM_NO_DISCARD
#if defined(_MSC_VER) && _MSC_VER >= 1700
#define COBOL_ORM_NO_DISCARD _Check_return_
#elif defined(__GNUC__) || defined(__clang__)
#define COBOL_ORM_NO_DISCARD __attribute__((warn_unused_result))
#else
#define COBOL_ORM_NO_DISCARD
#endif
#endif

/** @brief Library semantic version string. */
#define COBOL_ORM_VERSION_STR "0.1.0"

#endif /* COBOL_ORM_EXPORT_H */
