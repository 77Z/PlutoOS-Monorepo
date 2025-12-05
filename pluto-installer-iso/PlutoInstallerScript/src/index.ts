// BE AWARE!! This is some messy code...

import { input, select, confirm, password } from '@inquirer/prompts';
import { exec } from 'child_process';
import { promisify } from 'util';
import chalk from 'chalk';
import { existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from 'fs';
import cliSpinners from "cli-spinners";
import ora from "ora";
import { exit } from 'process';

const isDevMode = (): boolean => process.env.DEV === "1";

let apiURL = "https://pluto-freeze.77z.dev/api/v1";
if (isDevMode()) apiURL = "http://rgbhateclub:8787/api/v1";


const execCommand = promisify(exec);

async function executeCommand(command: string) {
	try {
		const { stdout, stderr } = await execCommand(command);
		if (stderr) {
			console.error(`Error: ${stderr}`);
		}
		return stdout.trim();
	} catch (error) {
		if (error instanceof Error) {
			console.error(`Execution failed: ${error.message}`);
		} else {
			console.error('Execution failed with an unknown error.');
		}
		throw error;
	}
}

interface LatestVersionInfo {
	stable: {
		latestVersion: string;
		releaseDate: string;
		bundleURL: string;
		bundleName: string;
	};
	beta: {
		latestVersion: string;
		releaseDate: string;
		bundleURL: string;
		bundleName: string;
	};
	chainloader: {
		latestVersion: string;
		releaseDate: string;
		bundleURL: string; // not yet used
		bundleName: string;
	};
	server: string;
};

async function getPlutoLatestVersionInfo(): Promise<LatestVersionInfo> {
	try {
		const res = await fetch(`${apiURL}/latestVersions`);
		return await res.json() as LatestVersionInfo;
	} catch (e) {
		throw new Error("Failed to get version info from server");
	}
}

async function hasInternetConnection(): Promise<boolean> {
	try {
		const res = await fetch(apiURL, { method: "HEAD" });
		return res.ok;
	} catch {
		return false;
	}
}

function getUUIDfromBlkidOutput(blkidData: string[], devPath: string): string | null {

	// Example data
	// /dev/nvme0n1p3: UUID="f89d4c25-1963-40a1-a92f-6091362ca396" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="6e2edffe-1884-47da-9a17-20ba18ae17f9"

	for (let i = 0; i < blkidData.length; i++) {
		if (blkidData[i].startsWith(devPath)) {
			const stringToParse = blkidData[i]; // see example data above
			const uuidExtractPart1 =  stringToParse.substring(stringToParse.indexOf(`UUID="`) + 6);
			return uuidExtractPart1.substring(0, uuidExtractPart1.indexOf(`"`));
		}
	}

	return null;
}

async function main() {
	// verify we are running on the live ISO to not mess up anyone's real
	// systems by accident :/
	try { statSync("/version"); }
	catch (error) {
		console.error("Not running on PlutoOS Installer ISO!");
		process.exit(1);
	}

	console.log(chalk.green("PlutoOS Installer v0.2.0"));

	if (isDevMode()) {
		console.log(chalk.redBright("-------------------------------------"));
		console.log(chalk.redBright("Installer running in DEVELOPMENT MODE"));
		console.log(chalk.redBright("-------------------------------------"));
		console.log("");
		console.log(chalk.redBright("Without a full PlutoOS development environment setup, things will break here!"));
	}

	process.stdout.write(chalk.bgWhite("checking for internet..."));
	if (!await hasInternetConnection()) {
		console.error(chalk.red("no internet connection, i can't reach 77Z servers!"));
		process.exit(1);
	}

	process.stdout.clearLine(0);
	process.stdout.cursorTo(0);

	console.log(chalk.green("✔ connected to data server!"))

	const feedback = await executeCommand("lsblk --all --raw -d");
	const feedbackSplit = feedback.split("\n");
	
	feedbackSplit.shift();
	
	for (let i = 0; i < feedbackSplit.length; i++) {
		feedbackSplit[i] = feedbackSplit[i].split(" ")[0];
	}
	
	for (let i = 0; i < feedbackSplit.length; i++) {
		if (feedbackSplit[i].startsWith("loop")) {
			feedbackSplit.shift();
			i--;
		}
	}
	
	const driveToPart = await select({
		message: "select drive to partition (not including loopbacks)",
		choices: feedbackSplit,
		loop: false,
	});

	const osEdition = await select({
		message: "PlutoOS Edition (if unsure, pick PRODUCTION!!)",
		choices: ["DEVELOPMENT", "PRODUCTION"],
		loop: false,
		default: 1
	});
	
	const prettyName = await input({ message: "pretty name for primary user (you!) (GECOS field)", required: true });

	const userPassword = await password({ message: "password for user (you!)" });

	const rootPassword = await password({ message: "password for root user"});

	const unixTimezone = await input({
		message: "unix-style timezone",
		default: "America/Chicago",
		required: true,
		validate(value) {
			return existsSync(`/usr/share/zoneinfo/${value}`)
		},
	})

	const hostname = await input({
		message: "machine hostname",
		default: "pluto",
		required: true,
	})

	console.log("-------------- RECAP ------------------");
	console.log("");
	console.log(`installing to                : /dev/${driveToPart}`);
	console.log(`primary user pretty name     : ${prettyName}`);
	console.log(`timezone                     : ${unixTimezone}`);
	console.log(`hostname                     : ${hostname}`);
	console.log("");
	console.log("---------------------------------------");

	if (!await confirm({ message: "are you ok with these settings?" })) {
		process.exit(0);
	}

	console.log(chalk.green("✔ installing plutoos!"));

	const partitioningSpinner = ora({
		spinner: cliSpinners.bouncingBar,
		text: "partitioning drive..."
	});
	partitioningSpinner.start();

	// This is so dumb
	writeFileSync("formatscript", `#!/usr/bin/env bash
(
echo g;
echo n;
echo ;
echo ;
echo +512M;
echo t;
echo 1;
echo n;
echo ;
echo ;
echo +512M;
echo t;
echo ;
echo 1;
echo n;
echo ;
echo ;
echo +512M;
echo t;
echo ;
echo 1;
echo n;
echo ;
echo ;
echo +10G;
echo t;
echo ;
echo 23;
echo n;
echo ;
echo ;
echo +10G;
echo t;
echo ;
echo 23;
echo n;
echo ;
echo ;
echo ;
echo t;
echo ;
echo 42;
echo w;
) | fdisk /dev/${driveToPart}

`, { encoding: "utf-8" });

	await executeCommand(`bash -c "chmod +x formatscript && ./formatscript"`)

	partitioningSpinner.stopAndPersist({ text: "partitioned drive" });

	console.log(await executeCommand(`bash -c "lsblk --raw | grep '${driveToPart}*'"`));

	const partitions: string[] = (await executeCommand(`bash -c "lsblk --raw | grep '${driveToPart}*'"`)).split("\n");

	partitions.shift();

	for (let i = 0; i < partitions.length; i++) {
		partitions[i] = partitions[i].substring(0, partitions[i].indexOf(" "));
	}

	// format first 3 partitions
	const chainloaderPartPath = "/dev/" + partitions[0];
	const efiAPartPath        = "/dev/" + partitions[1];
	const efiBPartPath        = "/dev/" + partitions[2];
	const rootAPartPath       = "/dev/" + partitions[3];
	const rootBPartPath       = "/dev/" + partitions[4];
	const homePartPath        = "/dev/" + partitions[5];


	console.log("-------- partitions to format ---------");

	console.log(`chainloader : ${chainloaderPartPath}   --->  ExFAT`);
	console.log(`efi A       : ${efiAPartPath}   --->  EXT4`);
	console.log(`efi B       : ${efiBPartPath}   --->  EXT4`);
	console.log(`root A      : ${rootAPartPath}   --->  BTRFS (ZSTD)`);
	console.log(`root B      : ${rootBPartPath}   --->  BTRFS (ZSTD)`);
	console.log(`user home   : ${homePartPath}   --->  EXT4`);

	console.log("---------------------------------------");

	const formattingSpinner = ora({
		spinner: cliSpinners.bouncingBar,
		text: "formatting partitions..."
	});

	formattingSpinner.start();

	await executeCommand(`mkfs.fat -F32 ${chainloaderPartPath}`);
	await executeCommand(`mkfs.ext4 -F ${efiAPartPath}`);
	await executeCommand(`mkfs.ext4 -F ${efiBPartPath}`);
	await executeCommand(`mkfs.btrfs -f ${rootAPartPath}`);
	await executeCommand(`mkfs.btrfs -f ${rootBPartPath}`);
	await executeCommand(`mkfs.ext4 -F ${homePartPath}`);

	formattingSpinner.stopAndPersist({ text: "formatted partitions" });

	// Label partitions with a file in their root directories

	await executeCommand(`mount --mkdir ${chainloaderPartPath} /mnt/chainloader`);
	await executeCommand(`mount --mkdir ${efiAPartPath} /mnt/efiA`);
	await executeCommand(`mount --mkdir ${efiBPartPath} /mnt/efiB`);
	await executeCommand(`mount --mkdir ${rootAPartPath} -o compress=zstd /mnt/rootA`);
	await executeCommand(`mount --mkdir ${rootBPartPath} -o compress=zstd /mnt/rootB`);
	await executeCommand(`mount --mkdir ${homePartPath} /mnt/home`);

	writeFileSync(`/mnt/rootA/label`, "rootA", "utf-8");
	writeFileSync(`/mnt/rootB/label`, "rootB", "utf-8");

	await executeCommand(`dosfslabel ${chainloaderPartPath} CHAINLOADER`);

	await executeCommand(`e2label ${efiAPartPath} EFIA`);
	await executeCommand(`e2label ${efiBPartPath} EFIB`);

	// await executeCommand(`e2label ${rootAPartPath} ROOTA`);
	// await executeCommand(`e2label ${rootBPartPath} ROOTB`);

	await executeCommand(`btrfs filesystem label ${rootAPartPath} ROOTA`);
	await executeCommand(`btrfs filesystem label ${rootBPartPath} ROOTB`);

	await executeCommand(`e2label ${homePartPath} USERHOME`);

	const blkidOutput: string[] = (await executeCommand("blkid")).split("\n");

	const efiAUUID = getUUIDfromBlkidOutput(blkidOutput, efiAPartPath);
	const efiBUUID = getUUIDfromBlkidOutput(blkidOutput, efiBPartPath);
	const rootAUUID = getUUIDfromBlkidOutput(blkidOutput, rootAPartPath);
	const rootBUUID = getUUIDfromBlkidOutput(blkidOutput, rootBPartPath);
	const homeUUID = getUUIDfromBlkidOutput(blkidOutput, homePartPath);

	// ASSERT
	if (!efiAUUID || !efiBUUID || !rootAUUID || !rootBUUID || !homeUUID) {
		console.error(chalk.red("failed to get uuids!"));
		process.exit(1);
	}

	console.log("--------- persistant uuids ------------");
	console.log(`efi A       : ${efiAUUID}`);
	console.log(`efi B       : ${efiBUUID}`);
	console.log(`root A      : ${rootAUUID}`);
	console.log(`root B      : ${rootBUUID}`);
	console.log(`user home   : ${homeUUID}`);
	console.log("---------------------------------------");

	console.log(chalk.green("Writing partition uuid table to chainloader!"));

	/* writeFileSync("/mnt/chainloader/uuidtable", JSON.stringify({
		efiA: efiAUUID,
		efiB: efiBUUID,
		rootA: rootAUUID,
		rootB: rootBUUID,
		home: homeUUID,
		partToBoot: "A"
	}), 'utf-8'); */

	console.log(chalk.blueBright("Getting PlutoOS version info from server...."));

	const latestVersionInfo = await getPlutoLatestVersionInfo();

	const chainloaderSpinner = ora({
		spinner: cliSpinners.bouncingBar,
		text: "downloading chainloader..."
	});

	chainloaderSpinner.start();

	// get download authkey from our system
	const authkey = readFileSync("/etc/rauc/authkey", { encoding: "utf-8" });

	await executeCommand(`bash -c "wget -O /mnt/home/chainloader.tar.zst '${apiURL}/altDownload?key=${authkey}&bundleName=${latestVersionInfo.chainloader.bundleName}' &>> /dev/null"`);
	await executeCommand(`tar -xvf /mnt/home/chainloader.tar.zst -C /mnt/chainloader --no-same-owner`);
	await executeCommand(`rm /mnt/home/chainloader.tar.zst`);

	if (osEdition == "DEVELOPMENT") {
		await executeCommand(`bash -c "echo '1' > /mnt/chainloader/DEV"`);
	}

	chainloaderSpinner.stopAndPersist({ text: "downloaded chainloader" });

	// Setup home dir
	mkdirSync("/mnt/home/.etcOverlay");
	mkdirSync("/mnt/home/.etcOverlay/upper");
	mkdirSync("/mnt/home/.etcOverlay/work");
	mkdirSync("/mnt/home/.varOverlay");
	mkdirSync("/mnt/home/.varOverlay/upper");
	mkdirSync("/mnt/home/.varOverlay/work");
	mkdirSync("/mnt/home/.rauc");

	// reload filesystems so that they show in /dev/disks/by-label
	await executeCommand(`udevadm trigger`);

	console.log("Unmounting everything EXCEPT home (rauc data-directory) and chainloader");
	await executeCommand(`umount /mnt/efiA`);
	await executeCommand(`umount /mnt/efiB`);
	await executeCommand(`umount /mnt/rootA`);
	await executeCommand(`umount /mnt/rootB`);


	// inject linux kernel parameters to our running system to fake rauc options //
	await executeCommand(`cp /proc/cmdline /root/cmdline`); // copy existing params
	await executeCommand(`echo " rauc.external" >> /root/cmdline`); // edit params
	await executeCommand(`mount -n --bind -o ro /root/cmdline /proc/cmdline`); // overlay new cmdline to trick rauc

	const downloadSpinner = ora({
		spinner: cliSpinners.bouncingBar,
		text: "Downloading latest PlutoOS version..."
	});
	downloadSpinner.start();

	await executeCommand(`bash -c "wget -O /mnt/home/update.raucb '${apiURL}/altDownload?key=${authkey}&bundleName=${latestVersionInfo.stable.bundleName}' &>> /dev/null"`);

	downloadSpinner.stopAndPersist({ text: "Downloaded PlutoOS" });


	const raucSpinner = ora({
		spinner: cliSpinners.bouncingBar,
		text: "Installing PlutoOS now..."
	});
	raucSpinner.start();

	await executeCommand(`rauc install /mnt/home/update.raucb`);

	raucSpinner.stopAndPersist({ text: "PlutoOS installed!" });

	console.log("\n\n\nPost install routine now...");

	// Delete update bundle
	await executeCommand(`rm /mnt/home/update.raucb`);

	// Re-apply filesystem labels, as RAUC overwrites these during installation.
	// the chainloader and home should be unaffected, so we'll just do the other ones.
	await executeCommand(`e2label ${efiAPartPath} EFIA`);
	await executeCommand(`e2label ${efiBPartPath} EFIB`);

	await executeCommand(`e2label ${rootAPartPath} ROOTA`);
	await executeCommand(`e2label ${rootBPartPath} ROOTB`);

	// Setup home directory

	// Hopefully xdg makes the localized skeleton dirs for us.
	// Note this uses the skel dir from the live ISO. Probably not a big deal, but just something to note
	await executeCommand(`cp -r /etc/skel /mnt/home/main`);
	await executeCommand(`chown -R 1000:1000 /mnt/home/main`);
	await executeCommand(`chmod 710 /mnt/home/main`);


	await executeCommand(`umount /mnt/chainloader`);
	await executeCommand(`umount /mnt/home`);

	// we also need to set the root and user passwords in the etc overlay.
	// the best way that I can think of to go about this is to mount the root and setup the overlay like
	// we would in the real system, so we'd have to know which slot RAUC installed root to. (it's probably B, but we can't make assumptions)
	//TODO: I'm gonna assume it's B for now lol

	// assemble makeshift pluto fs
	await executeCommand(`mount ${rootBPartPath} /mnt/rootB`);
	await executeCommand(`mount ${chainloaderPartPath} /mnt/rootB/chainloader`);
	await executeCommand(`mount ${homePartPath} /mnt/rootB/home`);
	await executeCommand(`mount -t overlay overlay -o lowerdir=/mnt/rootB/etc,upperdir=/mnt/rootB/home/.etcOverlay/upper,workdir=/mnt/rootB/home/.etcOverlay/work /mnt/rootB/etc`);

	// set passwords
	await executeCommand(`bash -c "yes '${userPassword}' | passwd -R /mnt/rootB main"`);
	await executeCommand(`bash -c "yes '${rootPassword}' | passwd -R /mnt/rootB root"`);

	// pretty name
	await executeCommand(`usermod -R /mnt/rootB -c "${prettyName}" main`);

	// timezone
	await executeCommand(`ln -s /usr/share/zoneinfo/${unixTimezone} /mnt/rootB/etc/localtime`);

	// hostname
	await executeCommand(`echo "${hostname}" > /mnt/rootB/etc/hostname`);

	// lock screen on boot
	await executeCommand(`mkdir /mnt/rootB/home/.config`);
	await executeCommand(`bash -c "echo -e '[Daemon]\nLockOnStart=true' > /mnt/rootB/home/.config/kscreenlockerrc"`);
	await executeCommand(`chown -R 1000:1000 /mnt/rootB/home/.config`);
	await executeCommand(`chmod 710 /mnt/rootB/home/.config`);

	await executeCommand(`umount /mnt/rootB/etc`);
	await executeCommand(`umount /mnt/rootB/chainloader`);
	await executeCommand(`umount /mnt/rootB/home`);
	await executeCommand(`umount /mnt/rootB`);


	// efibootmgr to make system aware that this OS exists now...

	await executeCommand(`efibootmgr --create --disk /dev/${driveToPart} --part 1 --label "PlutoOS Chainloader" --loader "\\EFI\\GRUB\\grubx64.efi"`);

	// TODO: revert cmdline bind mount

	console.log(chalk.green("-------------------------------------------------------------"));
	console.log(chalk.green("DONE INSTALLING!!! REBOOT TO ENJOY YOUR BRAND NEW SYSTEM"));
	console.log(chalk.green("-------------------------------------------------------------"));

}

main().catch(error => {
	console.error(error.message);
});
