# yarndiff <yarn container log 1> <yarn container log 2>
A rudimentary command line utility for contrasting Apache Yarn container logs.

## Motivation
I have been troubleshooting Apache Yarn application issues full-time since around 2015. When a yarn application slows down or stops working, I try to find out more information such as: Were there any new errors or other kinds of log messages in the container logs which were not there before?

Yarn logs from two runs of the same application cannot be contrasted using a general purpose diff tool as there would be thousands of changes detected which are not useful for troubleshooting.

I have decided to automate this part my job function in the form of a bash script which examines yarn logs and identifies differences which I find useful when troubleshooting yarn application performance and functionality problems. 
  
## Description
yarndiff is a Linux command line utility which contrasts yarn logs from two runs of a yarn application and displays a sample log entry for each kind of log entry that is found to be unique to either of the log files.

For example, if a yarn application has been running without problems for years and then suddenly slows down or stops working, then I will pass in the container logs from both a known working run as well as the container logs from the run which had problems. With a little luck, the yarndiff output helps guide me towards the root cause and solution.

## Online Installation w/ CI
```console

mkdir ~/bin
chmod u+rx ~/bin
wget -O ~/bin/yarndiff https://github.com/darule0/yarndiff/blob/main/yarndiff?raw=true
chmod u+rx ~/bin/yarndiff

```



## Offline Installation w/o CI
```console

sudo mkdir /opt/yarndiff
sudo chmod o+rx /opt/yarndiff
sudo git clone https://github.com/darule0/yarndiff.git /opt/yarndiff
sudo chmod o+rx /opt/yarndiff/yarndiff.sh
sudo ln -s /opt/yarndiff/yarndiff.sh /usr/bin/yarndiff

```

## How to obtain container logs for a yarn application run?
The logs switch on the yarn command can be used to obtain container logs for a recently run yarn application.
```console
yarn logs -applicationId APP_ID > APP_ID_yarn.log
```

## Tutorial
```console

# install yarndiff w/ CI
mkdir ~/bin
chmod u+rx ~/bin
wget -O ~/bin/yarndiff https://github.com/darule0/yarndiff/blob/main/yarndiff?raw=true
chmod u+rx ~/bin/yarndiff

# display yarndiff usage
yarndiff

# contrast container logs from a two runs of the same yarn application
yarndiff container_log1 container_log2

```

![alt text](https://raw.githubusercontent.com/darule0/yarndiff/main/yarndiff.png)

## Directories Used
| directory | purpose |
| :--- | :--- |
| $HOME/.yarndiff.dd4b66ed-a43d-48ec-8e32-1b901bc8ea8e | The latest yarndiff is automatically downlaoded here when Online Installation w/ CI. |
| $HOME/.yarndiff | Intermediate data for yarndiff processing. |

## Container Log Parsing Logic
| special entry | purpose |
| :--- | :--- |
| container.log.file | name of input log4j file |
| container.count | number of lines which begin with the word "Container: "|

| pseudo code: regular expression list generation derived from each container log file |
| :--- |
```console
for each line in a container log
  keep only lines which contain CRIT or ERROR or WARN or INFO or DEBUG or TRACE
  remove lines which contain the phrase "has been replaced by"
  replace all of the following characters with a the wildcard character '.'
      0123456789^$*+-?()[]{}|—/\\
  keep only the first 80 characters
sort the regular expressions
remove any duplicate regular expressions
```
| pseudo code: contrast and use both regular expressions lists |
| :--- |
```console
diff regular expression lists
for both regular expression lists
  obtain sample from applicable container log
  obtain number of matches from applicable container log
```




