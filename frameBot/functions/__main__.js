const lib = require('lib')({token: process.env.STDLIB_SECRET_TOKEN});
/**
* An HTTP endpoint that acts as a webhook for HTTP request event
* @returns {object} workflow The result of your workflow steps
*/
module.exports = async (obj) => {
  // Prepare workflow object to store API responses
  
  let workflow = {};
  
  let jsonObj = JSON.parse(obj);

  
  // [Workflow Step 1]
  
  console.log(`Running slack.channels[@0.4.22].messages.create()...`);
  
  workflow.response = await lib.slack.channels['@0.4.22'].messages.create({
    channel: `#${jsonObj.project}`,
    text: jsonObj.text,
    attachments: null
  });

  return workflow;
};


// function format (text) {
// return '```' + text '```';
// }