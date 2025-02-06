// Tool for converting a 2880 x 2880 PNG into a JSON base location file.
// Used for pre-defined base locations so I can make amusing base layouts.
var fs = require("fs");
var PNG = require("pngjs").PNG;
var path = require("path");

if (process.argv.length === 2) {
  console.error("Expected at least one argument: input.png");
  process.exit(-1);
}

function levelPre(partName) {
  console.log(`{
          "name": "${partName}",
          "minLevel": 1,
          "bases": [`);
}

function levelBase(x, y, v) {
  console.log(`                {
            "x": ${x},
            "y": ${y},
            "vert": ${v}
        },`);
}

function levelPost(numBases) {
  console.log(`
            ],
            "numBases": ${numBases}
        }`);
}

fs.createReadStream(process.argv[2])
  .pipe(new PNG({ filterType: 4 }))
  .on("parsed", function () {
    // Sanity
    if (this.width !== 2880 && this.height !== 2880) {
      console.error("Expected 2880 x 2880 PNG image");
      process.exit(-1);
    }

    var emitPre = levelPre,
      emitObj = levelBase,
      emitPost = levelPost;
    var partName = path.parse(process.argv[2]).name;
    var numBases = 0

    emitPre(partName);

    for (var y = 0; y < this.height; y++) {
      for (var x = 0; x < this.width; x++) {
        var idx = (this.width * y + x) << 2;

        const r = this.data[idx];
        const g = this.data[idx + 1];
        const b = this.data[idx + 2];

        if (r === 255 && g === 0 && b === 0) {
          emitObj(x, y, false)
          numBases++
        }
        else if (r === 0 && g === 255 && b === 0) {
          emitObj(x, y, true)
          numBases++
        }
      }
    }

    emitPost(numBases);
  });
