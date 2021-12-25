# screenShotter

ScreenShotter is script what will make screenshots of your desktop and hold only different. It will keep all of them, but only different will pack to .tar file.

## Directories
Script will create directories:
- Downloads
  - $(date)
	  - screenshots - for holding all make screenshots
		- logs - for holding information about difference between screenshots
		  There file names will be contain useful information about difference between screenshots (nameFromScreenshots:ifSame:pixelsDifference:percentDifference:timeDifference)
		- tar - to put only different files

## Installation

Clone this repo, script will download additional application if needed
```sh
git clone https://github.com/Shirobachi/screenShotter.git
```

## Usage
### Run 
Run `screenShotter.sh $1 $2` file
$1 and $2 are optional where:
- $1 - time to wait between screenshots
- $2 - minimal difference between screenshots

### close
Use INT signal to close script (CTRL+C) or delete PID file from `/tmp/screenShotter.sh` (if you run in background it could be useful)


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
If is any feature what you would like to be added, you open issue :)

## License
[MIT](https://choosealicense.com/licenses/mit/)