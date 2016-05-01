---
title: Introduction to Biocluster and Linux
last_updated: 29-Mar-16
---

## What Is a Compute Cluster?

* A compute cluster is an assembly of CPU units, so called compute nodes that work together to perform many computations in parallel. To achieve this, an internal network (e.g. Infiniband interconnect) connects the nodes to a larger unit, while a head node controls the load and traffic across the entire system.

* Usually, users log into the head node to submit their compute requests via `qsub` to a queuing system provided by resource management and scheduling software, such as TORQUE and MAUI. The queuing system distributes the processes to the compute nodes in a controlled fashion.

* Because the head node controls the entire system, users should never run compute jobs on the head node directly!

* For code testing purposes, one can log into one of the nodes with `qsub -I` and run jobs interactively. Alternatively, one can log into the test node owl via ssh.

## Hardware Infrastructure

### Compute nodes

- Over 3,000 CPU cores
- 50 batch compute nodes, each with 64 CPU cores and 512GB RAM
- 6 high-memory nodes, each 32 CPU cores and 1024GB RAM
- 4 GPU nodes, each with 10,000 cuda cores
    
### Interconnect 
- FDR IB @56Gbs 

### Storage

- Parallel GPFS storage system with 1.5PB usable space
- Backup of same architecture and similar amount

### User traffic

- Compute tasks need to be submitted via `qsub`
- Biocluster headnode only for login, not for compute tasks!
- Monitor cluster activity: `qstat` or `qstatMonitor`

### Manuals

- [Biocluster Manual](http://manuals.bioinformatics.ucr.edu/home/hpc)
- [Linux Manual](http://manuals.bioinformatics.ucr.edu/home/linux-basics#TOC-Exercises)


## Log into Biocluster

+ Login command on OS X or Linux 

{% highlight sh %}
ssh -X user@biocluster.ucr.edu
{% endhighlight %}
  
Type password

+ Windows: provide same information in [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
    
    + Host name: `biocluster.ucr.edu`
    + User name: ...
    + Password: ...


## Important Linux Commands

Finding help
{% highlight sh %}
man <program_name>
{% endhighlight %}
        
List content of current directory
{% highlight sh %}
ls
{% endhighlight %}

Print current working directory
{% highlight sh %}
pwd
{% endhighlight %}

Search in files and directories
{% highlight sh %}
grep
{% endhighlight %}

Word count
{% highlight sh %}
wc
{% endhighlight %}

Create directory
{% highlight sh %}
mkdir
{% endhighlight %}

Delete files and directories
{% highlight sh %}
rm
{% endhighlight %}

Move and rename files
{% highlight sh %}
mv
{% endhighlight %}

Copy files from internet to `pwd`
{% highlight sh %}
wget
{% endhighlight %}

Viewing files
{% highlight sh %}
less
{% endhighlight %}


## File Exchange

__GUI applications__

+ Windows: [WinSCP](http://winscp.net/eng/index.php)
+ Mac OS X: [CyberDuck](http://cyberduck.en.softonic.com/mac)
+ Win/OS X/Linux: [FileZilla](https://filezilla-project.org/)
        
__SCP command-line tool__

{% highlight sh %}
scp file user@remotehost:/home/user/ # From local to remote 
scp user@remotehost:/home/user/file . # From remote to local 
{% endhighlight %}

	
## STD IN/OUT/ERR, Redirect & Wildcards

Wildcard `*` to specify many files
{% highlight sh %}
file.*                        
{% endhighlight %}
Redirect `ls` output to file
{% highlight sh %}
ls > file                     
{% endhighlight %}
Specify file as input to command
{% highlight sh %}
command < myfile              
{% endhighlight %}
Append output of command to file
{% highlight sh %}
command >> myfile             
{% endhighlight %}
Pipe `STDOUT` of one command to another command
{% highlight sh %}
command1 | command2     
{% endhighlight %}
Turn off progress info 
{% highlight sh %}
command > /dev/null 
{% endhighlight %}
Pipe output of `grep` to `wc`
{% highlight sh %}
grep pattern file | wc        
{% endhighlight %}
Print `STDERR` to file
{% highlight sh %}
grep pattern nonexistingfile 2 > mystderr 
{% endhighlight %}

## Homework Assignment (HW2)

See HW2 page [here](http://girke.bioinformatics.ucr.edu/GEN242/mydoc/mydoc_homework_02.html).

## Permissions and ownership

List directories and files

{% highlight sh %}
ls -al 
{% endhighlight %}

The previous command shows something like this for each file/dir: `drwxrwxrwx`. The 
meaning of this syntax is as follows:
         
* `d`: directory
* `rwx`: read, write and execute permissions, respectively
    * first triplet: user permissions (u)
    * second triplet: group permissions (g)
    * third triplet: world permissions (o)

Example for assigning write and execute permissions to user, group and world
{% highlight sh %}
chmod ugo+rx my_file
{% endhighlight %}

* `+` causes the permissions selected to be added
* `-` causes them to be removed
* `=` causes them to be the only permissions that the file has.

Syntax for changing user & group ownership
{% highlight sh %}
chown <user>:<group> <file or dir> 
{% endhighlight %}


## Software and module system

* Over 500 software tools are currently installed on biocluster
* Most common research databases used in bioinformatics are available
* Support of most common programming languages used in research computing
* A module system is used to facilitate the management of software tools. This includes any number of versions of each software.
* New software install requests can be sent to support@biocluster.ucr.edu.
* To use software manged under the module system, users need to learn using some basic commands. The most common commands are listed below.

Print available modules
{% highlight sh %}
module avail
{% endhighlight %}

Print available modules starting with R
{% highlight sh %}
module avail R
{% endhighlight %}

Load default module R
{% highlight sh %}
module load R
{% endhighlight %}

Load specific module R version
{% highlight sh %}
module load R/3.2.2
{% endhighlight %}

List loaded modules
{% highlight sh %}
module list
{% endhighlight %}

Unload module R
{% highlight sh %}
module unload R
{% endhighlight %}

Unload specific module R
{% highlight sh %}
module unload R/3.2.3-dev
{% endhighlight %}


## Big data storage

Each user accounts on biocluster comes only with 20GB of disk space. Much more disk space is 
available in a dedicated `bigdata` directory. How much space depends on the subscription 
of each user group. The path of `bigdata` and `bigdata-shared` is as follows:

* `/bigdata/labname/username`
* `/bigdata/labname/shared`

All lab members share the same bigdata pool. The course number `gen242` is used as `labname`
for user accounts adminstered under GEN242.

The disk usage of `home` and `bigdata` can be monitored on the [Biocluster Dashboard](https://dashboard.bioinfo.ucr.edu/).


## Queuing System 

Biocluster uses Torque/Maui as queuing and load balancing system. Any type of compute intensive
jobs need to be submitted via the `qsub` (see below) to the compute nodes. Much more detailed
information on this topic is available in the biocluster manual [here](http://manuals.bioinformatics.ucr.edu/home/hpc).

* Torque (PBS)
    * Load Balancing
    * Parallel Computing
* Maui
    * Resource Management
    * Job Scheduler

### Job submission with `qsub`

Basic job submission with `qsub`

{% highlight sh %}
echo ’command_args’ | qsub
qsub script_name.sh
{% endhighlight %}

Sample submission script, here called `script_name.sh` to run `my_script.R`

{% highlight sh %}
#!/bin/bash
cd $PBS_O_WORKDIR
Rscript my_script.R
{% endhighlight %}

Interactive session: logs user into node
{% highlight sh %}
qsub -I
{% endhighlight %}

Interactive session with specific resource requests
{% highlight sh %}
qsub -q batch -l nodes=1:ppn=2,mem=8gb,walltime=03:00:00 -I
{% endhighlight %}

Submit job to `batch` queue with specific resource requests (queue, nodes, cpu, memory, walltime)
{% highlight sh %}
qsub -q batch -l nodes=1:ppn=2,mem=8gb,walltime=03:00:00 script_name.sh
{% endhighlight %}

Submit job to `highmem` queue with specific resource requests 
{% highlight sh %}
qsub -q highmem -l nodes=1:ppn=2,mem=8gb,walltime=03:00:00 script_name.sh
{% endhighlight %}


`STDOUT` and `STDERROR` files generate by each job
{% highlight sh %}
SCRIPTNAME.sh.oJOBID or STDIN.oJOBID
SCRIPTNAME.sh.eJOBID or STDIN.eJOBID
{% endhighlight %}

### Monitoring jobs with `qstat`

List all jobs in queue
{% highlight sh %}
qstat
{% endhighlight %}

List jobs of a specific user
{% highlight sh %}
qstat -u <user>
{% endhighlight %}

Print more detailed information about jobs
{% highlight sh %}
qstat -tf1
{% endhighlight %}

Custom command to summarize cluster activity
{% highlight sh %}
qstatMonitor
{% endhighlight %}

### Deleting and altering jobs 

Delete a single job
{% highlight sh %}
qdel <JOBID> # Delete single job
{% endhighlight %}

Delete all jobs of a user
{% highlight sh %}
qselect -u <user> | xargs qdel # All jobs of a user
{% endhighlight %}

Altering jobs with `qalter` (here walltime)
{% highlight sh %}
qalter -l walltime=8:00 <JOBID>
{% endhighlight %}

## Text/code editor options

* __Vi/Vim/Neovim__: Non-graphical (terminal-based) editor. Vi is guaranteed to be available on any system. Vim is the improved version of vi.
* __Emacs__: Non-graphical or window-based editor. You still need to know keystroke commands to use it. Installed on all Linux distributions and on most other Unix systems.
* __XEmacs__: More sophisticated version of emacs, but usually not installed by default. All common commands are available from menus. Very powerful editor, with built-in syntax checking, Web-browsing, news-reading, manual-page browsing, etc.
* __Pico__: Simple terminal-based editor available on most versions of Unix. Uses keystroke commands, but they are listed in logical fashion at bottom of screen. 
* __Nano__: A simple terminal-based editor which is default on modern Debian systems. 
* __Atom__: Modern text editor developed by GitHub project.

### Why does it matter?

To work efficiently on remote systems like a computer cluster, it is essential
to learn how to work in a pure command-line interface. GUI environments like
RStudio and similar coding environments are not suitable for this. In addition,
there is a lot of value of knowing how to work in an environment that is not
restricted to a specific programming language. Therefore, this class embraces
RStudio where it is useful, but for working on remote systems like biocluster, it 
uses Vim and Tmux. Both are useful for many programming languages.
Combinded with the `vim-r` plugin they also provide a powerful command-line working
environment for R. The following provides a brief introduction to this environment.

### Vim overview

The following opens a file (here `myfile`) with vim
{% highlight sh %}
vim myfile.txt
{% endhighlight %}

Once you are in Vim the most important commands are:

* `i`: The `i` key brings you into the insert mode for typing. 
* `Esc`: The `Esc` key brings you out of the insert mode.
* `:`: The `:` key starts the command mode at the bottom of the screen.

Use the arrow keys to move your cursor in the text. Using `Fn Up/Down key` allows to page through
the text quicker. In the following command overview, all commands starting with `:` need to be typed in the command mode. 
All other commands are typed in the normal mode after pushing the `Esc` key. 

Important modifier keys to control vim

* `:w`: save changes to file. If you are in editing mode you have to hit `Esc` first.
* `:q`: quit file that has not been changed
* `:wq`: save and quit file
* `:!q`: quit file without saving any changes

### Useful resources for learning vim

* [Interactive Vim Tutorial](http://www.openvim.com)
* [Official Vim Documentation](http://vimdoc.sourceforge.net/)
* [UCR Linux Manual](http://manuals.bioinformatics.ucr.edu/home/linux-basics#TOC-Vim-Manual)

## Vim-R-Tmux essentials
Terminal-based Working Environment for R: [Vim-R-Tmux](http://manuals.bioinformatics.ucr.edu/home/programming-in-r/vim-r)

<center><img title="Vim-R-Tmux" src="Rbasics_files/screenshot.png" ></center>
<center>Vim-R-Tmux IDE for R</center>

### Basics

Tmux is a terminal multiplexer that allows to split terminal windows and to deattach/reattach to
existing terminal sessions. Combinded with the `vim-r` plugin it provides a powerful command-line working 
environment for R where users can send code from a script to the R console or command-line.
Both tmux and the `vim-r` plugin need to be installed on a system. On Biocluster both are configured
in each user account. A detailed user manual is available [here](http://manuals.bioinformatics.ucr.edu/home/programming-in-r/vim-r).
The following give a short introduction into the basic usage:

__1. Start tmux session__
{% highlight sh %}
tmux # starts a new tmux session 
tmux a #  attaches to an existing session 
{% endhighlight %}

__2. Open R script in vim__ 

This can be any of these file types: `*.R`, `*.Rnw` or `*.Rmd`.

{% highlight sh %}
vim myscript.R
{% endhighlight %}

__3. Open vim-connected R session by pressing the `F2` key__ 

This will open an R session in a separate tmux pane. Note, in the provided `.tmux.conf` file 
the command key binding has been reassigned from the tmux default `Ctrl-b` to `Ctrl-a`, 
and the shortcut for starting R from vim has be reassigned from `\rf` to `F2` in the `.vimrc` 
file. The command key binding `Ctrl-a` is the most important key sequence in order to move 
around in tmux. For instance, the key sequence `Ctrl-a o` will switch between the vim and R 
panes, and `Ctrl-a Ctrl-o` will swap the two panes. 

__4. Send R code vim to the R pane__

Single lines of code can be sent from vim to the R console by pressing the space bar. To send 
several lines at once, one can select them in vim's visual mode and then hit the space bar. 
Please note, the default command for sending code lines in the vim-r-plugin is `\l`. This key 
binding has been remapped in the provided `.vimrc` file to the space bar. Most other key 
bindings (shortcuts) still start with the `\` as LocalLeader, _e.g._ `\rh` opens the help for 
a function/object where the curser is located in vim. More details on this are given below.

### Important keybindings for vim

* `<F2>`: opens vim-connected R session; remapped in `.vimrc` from default `\rf` 
* `<spacebar>`: sends code from vim to R; here remapped in `.vimrc` from default `\l` 
* `:split` or `:vsplit`: splits viewport (similar to pane split in tmux)  
* `Ctrl-w-w`: jumps cursor to next viewport
* `Ctrl-w-r`: swaps viewports
* `Ctrl-s` and `Ctrl-x`: freezes/unfreezes vim (some systems)

### Important keybindings for tmux

__Pane-level commands__

* `Ctrl-a %`: splits pane vertically
* `Ctrl-a "`: splits pane horizontally
* `Ctrl-a-o`: jumps cursor to next pane
* `Ctrl-a Ctrl-o`: swaps panes
* `Ctrl-a <space bar>`: rotates pane arrangement

__Window-level comands__

* `Ctrl-a n`: switches to next tmux window 
* `Ctrl-a Ctrl-a`: switches to previous tmux window
* `Ctrl-a c`: creates a new tmux window 
* `Ctrl-a 1`: switches to specific tmux window selected by number

__Session-level comands__

* `Ctrl-a d`: detaches from current session
* `Ctrl-a s`: switch between available tmux sesssions
* `$ tmux new -s <name>`: starts new session with a specific name
* `$ tmux ls`: lists available tmux session(s)
* `$ tmux attach -t <id>`: attaches to specific tmux session  
* `$ tmux attach`: reattaches to session 
* `$ tmux kill-session -t <id>`: kills a specific tmux session
* `Ctrl-a : kill-session`: kills a session from tmux command mode that can be initiated with `Ctrl-a :`

