/* Information about the specified file.
 * Copyright (C) 2003 Sami Kerola
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * You can contact the authors using the following email addresses:
 * Sami Kerola <kerolasa@iki.fi> */

/* gcc -O2 -Wall -pedantic stat.c -o stat && strip stat */
                 
#include<stdio.h>
#include<sys/types.h>
/* On solaris you need mkdev.h */
/* #include<sys/mkdev.h> */
#include<sys/stat.h>
#include<unistd.h>
#include<pwd.h>
#include<grp.h>
#include<time.h>

int printstat(char *filename, struct stat *fs);
void mode_string(mode_t mode, char *str);
int extrabits(mode_t bits);
int ftypelet (mode_t bits);

int main(int argc, char **argv) {
    struct stat fs;
    int i;

    for(i = 1; i < argc; i++) {
        if(i > 1) {
            printf("------------------\n");
        }
        if(stat(argv[i], &fs)) {
            perror(argv[i]);
            continue;
        }
        printstat(argv[i], &fs);
    }
    return(0);
}

int printstat(char *filename, struct stat *fs) {
    struct passwd *username;
    struct group *groupname;
    char modebuf[10];
    int extras;
    modebuf[9] = '\0';

    printf("file name         : %s\n", filename);
    printf("device            : major %d, minor %d\n", (int)major(fs->st_dev), (int)minor(fs->st_dev));
    printf("inode             : %d\n", (int)fs->st_ino);
    mode_string(fs->st_mode, modebuf);
    printf("file type         : ");
    ftypelet(fs->st_mode);
    printf("\n");
    if(fs->st_rdev != 0) {
        printf("inode device      : major %d, minor %d\n", (int)major(fs->st_rdev), (int)minor(fs->st_rdev));
    }
    printf("permissions       : %s\n", modebuf);
    extras = extrabits(fs->st_mode);
    switch(extras) {
        case 0:
            break;
        case 1:
            printf("extrabits         : setuid\n");
            break;
        case 2:
            printf("extrabits         : setgid\n");
            break;
        case 3:
            printf("extrabits         : setuid and setgid\n");
            break;
        case 4:
            printf("extrabits         : sticky bit\n");
            break;
        case 5:
            printf("extrabits         : setuid and sticky bit\n");
            break;
        case 6:
            printf("extrabits         : setgid and sticky bit\n");
            break;
        case 7:
            printf("extrabits         : suid, setgid and sticky bit\n");
            break;
    }
    printf("uid               : %d ", (int)fs->st_uid);
    username = getpwuid(fs->st_uid);
    if(username != NULL) {
        printf("(%s)\n", username->pw_name);
    } else {
        printf("\n");
    }
    printf("gid               : %d ", (int)fs->st_gid);
    groupname = getgrgid(fs->st_gid);
    if(groupname != NULL) {
        printf("(%s)\n", groupname->gr_name);
    } else {
        printf("\n");
    }
    printf("file size         : %d\n", (int)fs->st_size);
    printf("access time       : %s", ctime(&fs->st_atime));
    printf("modification time : %s", ctime(&fs->st_mtime));
    printf("change time       : %s", ctime(&fs->st_ctime));
    
    return(0);
}

/* Below this comment some code that is copied from GNU file
 * management utilities. */

#if !S_IRUSR
# if S_IREAD
#  define S_IRUSR S_IREAD
# else
#  define S_IRUSR 00400
# endif
#endif

#if !S_IWUSR
# if S_IWRITE
#  define S_IWUSR S_IWRITE
# else
#  define S_IWUSR 00200
# endif
#endif

#if !S_IXUSR
# if S_IEXEC
#  define S_IXUSR S_IEXEC
# else
#  define S_IXUSR 00100
# endif
#endif

#if !S_IRGRP
# define S_IRGRP (S_IRUSR >> 3)
#endif
#if !S_IWGRP
# define S_IWGRP (S_IWUSR >> 3)
#endif
#if !S_IXGRP
# define S_IXGRP (S_IXUSR >> 3)
#endif
#if !S_IROTH
# define S_IROTH (S_IRUSR >> 6)
#endif
#if !S_IWOTH
# define S_IWOTH (S_IWUSR >> 6)
#endif
#if !S_IXOTH
# define S_IXOTH (S_IXUSR >> 6)
#endif

#ifdef STAT_MACROS_BROKEN
# undef S_ISBLK
# undef S_ISCHR
# undef S_ISDIR
# undef S_ISFIFO
# undef S_ISLNK
# undef S_ISMPB
# undef S_ISMPC
# undef S_ISNWK
# undef S_ISREG
# undef S_ISSOCK
#endif /* STAT_MACROS_BROKEN.  */

#if !defined S_ISBLK && defined S_IFBLK
# define S_ISBLK(m) (((m) & S_IFMT) == S_IFBLK)
#endif
#if !defined S_ISCHR && defined S_IFCHR
# define S_ISCHR(m) (((m) & S_IFMT) == S_IFCHR)
#endif
#if !defined S_ISDIR && defined S_IFDIR
# define S_ISDIR(m) (((m) & S_IFMT) == S_IFDIR)
#endif
#if !defined S_ISREG && defined S_IFREG
# define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#endif
#if !defined S_ISFIFO && defined S_IFIFO
# define S_ISFIFO(m) (((m) & S_IFMT) == S_IFIFO)
#endif
#if !defined S_ISLNK && defined S_IFLNK
# define S_ISLNK(m) (((m) & S_IFMT) == S_IFLNK)
#endif
#if !defined S_ISSOCK && defined S_IFSOCK
# define S_ISSOCK(m) (((m) & S_IFMT) == S_IFSOCK)
#endif
#if !defined S_ISMPB && defined S_IFMPB /* V7 */
# define S_ISMPB(m) (((m) & S_IFMT) == S_IFMPB)
# define S_ISMPC(m) (((m) & S_IFMT) == S_IFMPC)
#endif
#if !defined S_ISNWK && defined S_IFNWK /* HP/UX */
# define S_ISNWK(m) (((m) & S_IFMT) == S_IFNWK)
#endif
#if !defined S_ISDOOR && defined S_IFDOOR /* Solaris 2.5 and up */
# define S_ISDOOR(m) (((m) & S_IFMT) == S_IFDOOR)
#endif
#if !defined S_ISCTG && defined S_IFCTG /* MassComp */
# define S_ISCTG(m) (((m) & S_IFMT) == S_IFCTG)
#endif

int extrabits(mode_t bits) {
    int thebits = 0;
#ifdef S_ISUID
    if (bits & S_ISUID) {
	    thebits = 1;
    }
#endif
#ifdef S_ISGID
    if (bits & S_ISGID) {
	    thebits += 2;
    }
#endif
#ifdef S_ISVTX
    if (bits & S_ISVTX) {
	    thebits +=4;
    }
#endif
    return(thebits);
}

int ftypelet (mode_t bits) {
#ifdef S_ISBLK
    if (S_ISBLK (bits)) {
        printf("block special");
        return(0);
    }
#endif
    if (S_ISCHR (bits)) {
        printf("character special");
        return(0);
    }
    if (S_ISDIR (bits)) {
        printf("directory");
        return(0);
    }
    if (S_ISREG (bits)) {
        printf("regular file");
        return(0);
    }
#ifdef S_ISFIFO
    if (S_ISFIFO (bits)) {
        printf("fifo");
        return(0);
    }
#endif
#ifdef S_ISLNK
    if (S_ISLNK (bits)) {
        printf("symbolic link");
        return(0);
    }
#endif
#ifdef S_ISSOCK
    if (S_ISSOCK (bits)) {
        printf("socket");
        return(0);
    }
#endif
#ifdef S_ISMPC
    if (S_ISMPC (bits)) {
        printf("multiplexor file");
        return(0);
    }
#endif
#ifdef S_ISNWK
    if (S_ISNWK (bits)) {
        printf("network special");
        return(0);
    }
#endif
#ifdef S_ISDOOR
    if (S_ISDOOR (bits)) {
        printf("door");
        return(0);
    }
#endif
#ifdef S_ISCTG
    if (S_ISCTG (bits)) {
        printf("contigous data");
        return(0);
    }
#endif

/* The following two tests are for Cray DMF (Data Migration
 * Facility), which is a HSM file system.  A migrated file has a
 * `st_dm_mode' that is different from the normal `st_mode', so
 * any tests for migrated files should use the former.  */

#ifdef S_ISOFD
    if (S_ISOFD (bits)) {
        printf("an off-line (regular) file");
        return(0);
    }
#endif
#ifdef S_ISOFL
    if (S_ISOFL (bits)) {
        printf("an off-line (regular) file");
        return(0);
    }
#endif
    return(0);
}

void mode_string (mode_t mode, char *str) {
  str[0] = mode & S_IRUSR ? 'r' : '-';
  str[1] = mode & S_IWUSR ? 'w' : '-';
  str[2] = mode & S_IXUSR ? 'x' : '-';
  str[3] = mode & S_IRGRP ? 'r' : '-';
  str[4] = mode & S_IWGRP ? 'w' : '-';
  str[5] = mode & S_IXGRP ? 'x' : '-';
  str[6] = mode & S_IROTH ? 'r' : '-';
  str[7] = mode & S_IWOTH ? 'w' : '-';
  str[8] = mode & S_IXOTH ? 'x' : '-';
}
