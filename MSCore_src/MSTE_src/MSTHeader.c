
#include "MSTE_Private.h"

void					MSTHeader_initNull(
struct MSTHeader*			self)
{
	self->ver = NULL;
	self->cnt = 0;
	self->crc = NULL;
}


int					MSTHeader_init(
struct MSTHeader*			self,
const char*				ver,
int					cnt,
const char*				crc)
{
	MSTHeader_initNull(self);
	self->cnt = cnt;
	if ((self->ver = CCreateBufferWithBytes(ver, strlen(ver))) == NULL
		|| (self->crc = CCreateBufferWithBytes(crc, strlen(crc)))
									== NULL)
	{
		MSTHeader_halt(self);
		return 1;
	}
	return 0;
}


int					MSTHeader_initFromReader(
struct MSTHeader*			self,
struct MSTReader*			reader)
{
	MSTHeader_initNull(self);
	if ((self->ver = MSTReader_newStrRead(reader, 9)) == NULL
		|| MSTReader_intRead(reader, &self->cnt)
		|| (self->crc = MSTReader_newStrRead(reader, 12)) == NULL)
	{
		MSTHeader_halt(self);
		return 1;
	}
	return 0;
}


void					MSTHeader_halt(
struct MSTHeader*			self)
{
	if (self->ver != NULL)
		RELEASE(self->ver);
	if (self->crc != NULL)
		RELEASE(self->crc);
}


int					MSTHeader_toWriter(
struct MSTHeader*			self,
struct MSTWriter*			reader)
{
	/* TODO */
	self = NULL;
	reader = NULL;
	return 0;
}


int					MSTHeader_cntGet(
struct MSTHeader*			self)
{
	return self->cnt;
}
