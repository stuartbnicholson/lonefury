// Lonestarfighter tool for converting a 320 x 240 PNG into a JSON level part file.
var fs = require("fs");
var PNG = require("pngjs").PNG;
var path = require("path");

const rgbToHex = (r, g, b) => {
  return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
};

const rgbToGameObj = {
  "#ac3232": "a", // Asteroid
  "#df7126": "e", // Enemy Bomber
  "#99e550": "b", // Enemy Base
};

if (process.argv.length === 2) {
  console.error("Expected at least one argument: input.png");
  process.exit(-1);
}

fs.createReadStream(process.argv[2])
  .pipe(new PNG({ filterType: 4 }))
  .on("parsed", function () {
    // Sanity
    if (this.width !== 320 && this.height !== 240) {
      console.error("Expected 320 x 240 PNG image");
      process.exit(-1);
    }

    var partName = path.parse(process.argv[2]).name;
    const pre = `"${partName}": {
            "objs": [`;
    console.log(pre);

    for (var y = 0; y < this.height; y++) {
      for (var x = 0; x < this.width; x++) {
        var idx = (this.width * y + x) << 2;

        const r = this.data[idx];
        const g = this.data[idx + 1];
        const b = this.data[idx + 2];

        if (r !== g || g !== b || r !== b) {
          const obj = rgbToGameObj[rgbToHex(r, g, b)];
          console.log(`                {
                    "x": ${x},
                    "y": ${y},

                    "obj": "${obj}"
                },`);
        }
      }
    }

    const post = `
            ]
        }`;
    console.log(post);
  });
