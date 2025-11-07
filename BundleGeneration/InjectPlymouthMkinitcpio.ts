console.log("[SUB-TASK] Injecting Plymouth into mkinitcpio.conf...");

const mkinitcpio = Deno.readTextFileSync("./targetroot/etc/mkinitcpio.conf")
    .split("\n");

for (let i = 0; i < mkinitcpio.length; i++) {
    if (mkinitcpio[i].startsWith("HOOKS=(")) {
        const hooksLine = mkinitcpio[i];

        mkinitcpio[i] = hooksLine.replaceAll("base ", "base plymouth ");

        break;
    }
}

const newMkinitcpio: string[] = [];

// While we're here, we can squish down the size of this file... cause space saving is good!
for (let i = 0; i < mkinitcpio.length; i++) {
    if (mkinitcpio[i] == "\n") continue;

    if (mkinitcpio[i].startsWith("#")) continue;

    newMkinitcpio.push(mkinitcpio[i]);
}

Deno.writeTextFileSync(
    "./mkinitcpio.conf",
    newMkinitcpio.join("\n"),
);
