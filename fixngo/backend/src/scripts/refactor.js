const fs = require('fs');
const path = require('path');

const replaceInFile = (filePath, replacements) => {
  let content = fs.readFileSync(filePath, 'utf8');
  let changed = false;
  for (const { search, replace } of replacements) {
    if (content.includes(search)) {
      content = content.replaceAll(search, replace);
      changed = true;
    }
  }
  if (changed) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated ${filePath}`);
  }
};

const controllersDir = path.join(__dirname, '../controllers');

// For files that ONLY deal with Technicians
const technicianFiles = [
  'technicianController.js',
  'technicianAppController.js',
  'technicianProfileController.js',
  'walletController.js',
  'ratingController.js'
];

technicianFiles.forEach(file => {
  replaceInFile(path.join(controllersDir, file), [
    { search: "const User = require('../models/userModel');", replace: "const Technician = require('../models/technicianModel');" },
    { search: "User.", replace: "Technician." }
  ]);
});

console.log('Done with simple replacements.');
