tcamake
=======

***Author***  tcarland@gmail.com  
***Version*** v0.2.1 - 20190731 


### Overview:

  **tcamake** is a build environment for code projects using GNU make. 
It is not its own 'make' implementation. It simply wraps the use of 
Gnu 'automake' providing preset platform specific dependencies and 
environments.  

  The goal is to provide a clean and simplified method of managing large 
project and sub-project dependencies in a common set of configurations 
which allows for clean and logical Makefiles.  

  The system has been used reliably for years and serves as my excuse to 
avoid the GNU autoconf toolset. In fact, while certainly not as powerful 
as the autotools, the Makefile template heirarchy lends itself nicely 
as a build system mechanism or even in addition to the gnu autotools. It is 
surprisingly capable and even useful for managing a build environment 
for very large projects.   

  **tcamake** is simply an include heirarchy that defines all of the
dependencies of projects within the build system. It does not determine 
compiler capabilities and library function checks to the extent of the
Gnu autotools.  If needed, gnu's autoconf could still be used per 
project if desired.   

### Layout (TOPDIR):

  The build environment layout is specific to a directory structure 
starting with a root directory that is referred to as the 'top' directory 
or $TOPDIR. This can be for a specific project or group of projects as needed. 
The term project is used loosely to define an encompassing environment 
that may, in fact, contain many projects and is frequently referred to as 
a 'workspace' or 'repository'. This is often the root VCS path.  

  An instance of the 'tcamake' build environment must exist at the 
workspace top-level. For example, assume we have the following code 
repository, '~/src/repoX'. 'repoX' is considered the workspace 
or TOPDIR. The build system would then be '$TOPDIR/tcamake' or in this
case, '~/src/repoX/tcamake'.  

  Each subsequent project Makefile beneath the top-level must define 
the TOPDIR environment variable to point to the relative root of the workspace.
Additionally, each Makefile must include **$TOPDIR/tcamake/project_defs**.  

  Templates for these Makefiles are provided in the templates subdirectory
and can be modified as needed. A given project can then have a default 
Makefile installed by using the init script **tcamake_init_project.sh**.  

  A given build environment could potentially have more than one top-level 
directory. Each top-level is essentially a Makefile that includes 
'./tcamake/project_defs'. This simply allows some global project settings
that sublevel Makefiles might need.  

  The environment variable **TCAMAKE_PROJECT** reflects that a tcamake build 
repository exists which can be used by sub-level Makefiles that wish to 
distinguish between build environments versus full distribution. The goal of 
this feature is to allow a standalone distribution expecting to find common
libraries that might exist elsewhere in a build environment to be 
found locally within the project as './common/' instead.   

### Files:

The Makefile hierarchy includes the following files:

 * **build_defs**  
    This is included once by the top-level or 'root' build Makefile and
    sets common environment vars to be used across projects or the build
    environment.  

 * **project_defs**  
    This is the Makefile 'include' entry-point included by project Makefiles. 
    It pulls in both the dependencies and the platform environment via the 
    'depends' and 'environment' files respectively. 

 * **depends**  
    The file for defining all project dependencies. This is the only file 
    that should need updating. Since these dependencies generate our **INCLUDE** 
    and **LIB** variables, order can be important.  In general, the order should 
    sort projects with the most dependencies before projects with the least 
    dependencies.  

 * **autodepend**  
    An internal file for defining build commands and is the last file included 
    by 'depends'.  This file should NOT need to be modified.

 * **environment**  
    This is included automatically for each project by **project_defs** 
    to initiate the platform's desired compiler flags and other 
    platform specific macros.
    This file should NOT need to be modified other than to add new 
    dependencies or platform environment profiles.


### Scripts:

  A few scripts simply to assist in building or initializing projects. 
They make use of the Makefile templates found in the 'tcamake/template' 
directory which also serve as good examples.   
  The build script is intended to be useful in creating project 
distributions suitable for export ensuring common dependencies are linked 
within a given project as needed.  
  
 * **tcamake_build.sh**  
    Some projects within the workspace may wish to be exported or built 
    independently of the workspace. This script will assist in creating a 
    project distribution by ensuring that links for needed dependencies 
    such as 'tcamake' itself or other common libs are generated. 
    Alternatively, it simply allows for building a project 
    while overriding TOPDIR.

 * **tcamake_init_project.sh**  
    Used to inititiate a new project within the workspace, providing 
    a base Makefile template.

 * **tcamake_init_workspace.sh**  
    Used to create a new workspace using the workspace template from 
    the tcamake project from which the script was called.


