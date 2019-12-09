#ifndef ROE_H
#define ROE_H

#include "xstatus.h"
#include "xil_printf.h"

#define _STR(x) #x
#define STR(x) _STR(x)




#define TRACE(f, status, ...) { \
	xil_printf("\nERROR:"); \
	xil_printf("\n\t File: " STR(__FILE__)); \
	xil_printf("\n\t Line: " STR(__LINE__)); \
	xil_printf("\n\t Call: " #f); \
	xil_printf("\n\t Retn: %d", status); \
	xil_printf("\n\t Info: " __VA_ARGS__); \
	xil_printf("\n"); \
}




// Return
// If f does not evaluate to XST_SUCCESS, print an error message
// Returns the value of f
#define _return_(f, ...) { \
	int f_eval = (f); \
	if ( f_eval != XST_SUCCESS ) { \
		TRACE(f, f_eval, __VA_ARGS__); \
	} \
	return f_eval; \
}


// Return-On-Error
// If f does not evaluate to XST_SUCCESS,
// print an error message and return the value of f
// Useful for tidying up Xilinx function calls with return codes
#define _return_if_error_(f, ...) { \
	int f_eval = (f); \
	if ( f_eval != XST_SUCCESS ) { \
		TRACE(f, f_eval, __VA_ARGS__); \
		return f_eval; \
	} \
}

#define _return_if_null_(f, ...) { \
	void *f_eval = (f); \
	if ( f_eval == NULL ) { \
		TRACE(f, f_eval, __VA_ARGS__); \
		return XST_FAILURE; \
	} \
}

#define _return_if_(f, ...) { \
	int f_eval = (f); \
	if ( f_eval ) { \
		TRACE(f, f_eval, __VA_ARGS__); \
		return XST_FAILURE; \
	} \
}

#endif





// TODO: rename _R_ to something better e.g. return_and_print

/*
 *
 *
 *
 *
 * #ifndef ROE_H
#define ROE_H

#include <stdio.h>

#define _STR(x) #x
#define STR(x) _STR(x)




// Return always, print info if result not expected
// If f does not evaluate to expected, print an error message
// Returns the value of f
#define return_pne(f, expected, retval, ...) { \
	int status = (f); \
	if ( status != expected ) { \
		xil_printf("\nERROR:"); \
		xil_printf("\n\t File: " STR(__FILE__)); \
		xil_printf("\n\t Line: " STR(__LINE__)); \
		xil_printf("\n\t Call: " #f); \
		xil_printf("\n\t Retn: %d", status); \
		xil_printf("\n\t Info: " __VA_ARGS__); \
		xil_printf("\n"); \
	} \
	return status; \
}


// Return always, print info if result not successful
// Calls _RPNE_ expecting XST_SUCCESS
#define return_pns(f, ...) return_pne(f, XST_SUCCESSFUL, __VA_ARGS__)


#define TRACE(f, status, ...) { \
	xil_printf("\nERROR:"); \
	xil_printf("\n\t File: " STR(__FILE__)); \
	xil_printf("\n\t Line: " STR(__LINE__)); \
	xil_printf("\n\t Call: " #f); \
	xil_printf("\n\t Retn: %d", status); \
	xil_printf("\n\t Info: " __VA_ARGS__); \
	xil_printf("\n"); \
}


// Return if result not expected, print info if result not expected
// If f does not evaluate to expected,
// print an error message and return the value of f
// Useful for tidying up Xilinx function calls with return codes
#define return_if_not(f, expected, ...) { \
	int status = (f); \
	if ( status != expected ) { \
		TRACE(f, status, __VA_ARGS__) \
		return status; \
	} \
}

#define return_if(f, expected, ...) { \
	int status = (f); \
	if ( status == expected ) { \
		TRACE(f, status, __VA_ARGS__) \
		return status; \
	} \
}


// Return if result not successful, print info if result not successful
// Calls _RONE_ expecting XST_SUCCESS
#define return_if_error(f, ...) return_if_not(f, XST_SUCCESS, __VA_ARGS__)


#endif
 *
 *
 *
 *
 *
 *
 */
