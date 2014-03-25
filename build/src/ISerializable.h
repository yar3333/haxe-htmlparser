#ifndef ISERIALIZABLE_H
#define	ISERIALIZABLE_H

#include "common.h"
#include "Serializer.h"
#include "Unserializer.h"

class ISerializable
{
	public: virtual ~ISerializable();
	//public: virtual void hxSerialize(Serializer &s) = 0;
	//public: virtual void hxUnserialize(Unserializer &s) = 0;
};

#endif