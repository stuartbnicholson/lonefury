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

function levelPre(partName) {
  console.log(`"${partName[0]}": {
          "name": "${partName}",
          "objs": [`);
}

function levelObj(x, y, o) {
  console.log(`                {
            "x": ${x},
            "y": ${y},

            "obj": "${o}"
        },`);
}

function levelPost() {
  console.log(`
            ]
        }`);
}

function formationPre(partName) {
  console.log(`${partName} = {`);
}

var formLeaderX = null,
  formLeaderY;
function formationObj(x, y, o) {
  if (formLeaderX === null) {
    formLeaderX = x;
    formLeaderY = y;
  } else {
    console.log(`\tgeom.point.new(${x - formLeaderX}, ${y - formLeaderY}),`);
  }
}

function formationPost() {
  console.log(`}`);
}

fs.createReadStream(process.argv[2])
  .pipe(new PNG({ filterType: 4 }))
  .on("parsed", function () {
    // Sanity
    if (this.width !== 320 && this.height !== 240) {
      console.error("Expected 320 x 240 PNG image");
      process.exit(-1);
    }

    var emitPre = levelPre,
      emitObj = levelObj,
      emitPost = levelPost;
    var partName = path.parse(process.argv[2]).name;
    if (partName.includes("formation")) {
      emitPre = formationPre;
      emitObj = formationObj;
      emitPost = formationPost;
    }

    emitPre(partName);

    for (var y = 0; y < this.height; y++) {
      for (var x = 0; x < this.width; x++) {
        var idx = (this.width * y + x) << 2;

        const r = this.data[idx];
        const g = this.data[idx + 1];
        const b = this.data[idx + 2];

        if (r !== g || g !== b || r !== b) {
          const o = rgbToGameObj[rgbToHex(r, g, b)];
          emitObj(x, y, o);
        }
      }
    }

    emitPost();
  });
