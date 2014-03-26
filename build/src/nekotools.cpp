#include "nekotools.h"

value *getArrayPtr(value arr)
{
	if (!val_is_array(arr))
	{
		arr = val_field(arr, val_id("__a"));
	}
	return val_array_ptr(arr);
}

int getArraySize(value arr)
{
	if (!val_is_array(arr))
	{
		arr = val_field(arr, val_id("__a"));
	}
	return val_array_size(arr);
}
