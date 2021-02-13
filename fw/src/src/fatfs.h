
#ifndef FATFS_H
#define FATFS_H


#include "ff.h"

FATFS *make_fatfs();
int init_fatfs(FATFS *fatfs);

int fatfs_ls();

#endif
