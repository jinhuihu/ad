import jsdoc2md from 'jsdoc-to-markdown'
const apiDocs = await jsdoc2md.render({ files: 'tool/*.js' })

console.log(apiDocs)