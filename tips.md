# Some things I wrote down that helped me use Linux
Note: for all of these, replace USERNAME with your server username

## ToC:
- [val](#link)

## Inactive sessions (eg when you get kicked)
If you get kicked out of the server unexpectedly, some process may continue running.
Particularly for R, you can check this using the following:

`ps -eo user,pid,cputime,bsdstart,bsdtime,comm | grep USERNAME | grep R`

If R is still running, use `pkill -u USERNAME R` to kill it.
You may also want to check python processes if you use that (replace `R` with `python` for both commands).

## Killing running processes
Easiest way to kill a process is using `kill`. Get the PID of the process you want, using either the ps command (above) or `top -i` (press q to quit out of top). Then use `kill -9 PID` to kill the process.

## sed text replacements
Base sed command: `sed -i -e 's/SEARCH_TEXT/REPLACE_TEXT/g' FILE`
For reference:
- `-i` replaces the document in place
- `-e` tells sed that we use a regex command
- `/g` tells sed to replace all (otherwise replaces first instance on each line)

Some of the uses I use it for are as follows:
### Removing the first line of a file
This can be done with `tail` too, but I find it easier with sed, particularly as it can be done inplace (see above)

`sed -e 1d FILE`

### Adding chr to the start of each line
Useful for when dealing with files that need to be in a particular format, particularly from going from build 37 to build 38.

`sed -i 's/^/chr/' FILE`

Note: In my experience, I can't write this out to a file using `>`. It's probably not meant to, but thought it was worth noting as I use `>` or `>>` for a lot of things.

## Background processes

### tmux
I use tmux mostly for planned background processes and organisation:
The way I use it:
- Use `tmux new -s NAME` to create a new tmux session.
- Then run your processes like a normal terminal.
- To close tmux, press `ctrl + b` then let go of the keys and press `d`.
- You can list your sessions using `tmux ls` and return to your named session using `tmux attach -t NAME`.
- When you're finished with it, you can either just type `exit` in the tmux session, or you can use `ctrl + b` + `d` and then `tmux kill-session -t NAME`.

### Move something into the background process
If you started something running and it's taking ages, you can put it into a background process by typing `ctrl + z` and then enter `>bg`. This moves your process into the background and it will stay there until it's done.
If it still keeps running, I would kill it based on it's PID.
To do this, look up the PID using `ps -u USERNAME` and kill the particular process using `kill -9 PID`.

## Unique count of a column
Use awk.
`awk '{print $1}' FILE |sort|uniq -c`

## Jupyter lab with the server
The server can be particularly slow for using things with X11 forwarding (eg RStudio or STATA). I use Jupyter to get around this as it allows port-forwarding. The way to use it is to load jupyter in one terminal (when logged into the server), then conenct to the port in the other (swap out `8889` for a port that's open, eg other 4-digit numbers):
```bash
# Terminal 1:
ssh user@server.ac.uk
jupyter lab --no-browser --port=8889

# Terminal 2:
ssh -CNL localhost:8889:localhost:8889 user@server.ac.uk
```
Note: terminal 2 will just hang like nothing's happening.

Then open the jupyter instance in a web browser (copy and paste the part that comes up: `http://localhost:8889/lab?token=xxxxxxxx`)

To look for some free ports use the following:
`ps au | grep 'jupyter' | grep 'port'`

### Jupyter QoL
I also added some additions to my Jupyter lab to make things a bit easier.
First, I created a separate conda environment that contains only jupyter lab and the associated packages for it. I following commands can be used to generate a similar environment:
```bash
module load Anaconda3
conda create --name jupyter_env
source activate jupyter_env
conda install jupyterlab
conda install nb_conda_kernels
conda install jupytext
```
By using this environment, I can keep my Jupyter lab instance up-to-date without affecting other environments I'm working in. I can also access any of these environemnts by changing the kernel of the notebook (this is what `nb_conda_kernels` is for). Finally jupytext allows me to work in a notebook environment, but particuarly for functions or clean code, write in a plain .R or .py file.

I also made a file to load this a bit faster and so I don't have to remember the port I chose. Just stick the following into a file in your home directory (eg `run_jupyter.sh`) and run it using `. ~/run_jupyter.sh`:
```bash
module load Anaconda3
source activate jupyter_env
jupyter lab --no-browser --port=8889
```

I've also added an R kernel to jupyter. It can be a bit more annoying with the server so recommend making a separate conda environment with R for a clean install. Otherwise, you can use available one on the server: `module load R`. Open up R (using the command: `R`) and run the following lines:
```R
install.packages('IRkernel')
IRkernel::installspec(user=TRUE)
```
You should see R in your kernel options now.

