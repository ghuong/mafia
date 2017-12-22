// Inspired by: http://snipplr.com/view/66619/

// Send non-AJAX HTTP requests in javascript by creating a form
// and submitting it
function httpRequest(url, data = {}, method = "post") {
  var myForm = document.createElement("form");
  myForm.action = url;
  
  if (method === "get") {
    myForm.method = "get";
  } else {
    myForm.method = "post";

    // Rails workaround to submit non-POST requests
    if (method !== "post") {
      appendInputFieldToForm(myForm, "_method", method);
    }
  }

  // CSRF Token
  var CSRF_TOKEN = $('meta[name=csrf-token]').attr('content');
  appendInputFieldToForm(myForm, "authenticity_token", CSRF_TOKEN);

  // data payload to submit
  for (var key in data) {
    appendInputFieldToForm(myForm, key, data[key]);
  }

  document.body.appendChild(myForm) ;
  myForm.submit() ;
  document.body.removeChild(myForm) ;
}

function appendInputFieldToForm(form, name, value) {
  var inputField = document.createElement("input");
  inputField.setAttribute("name", name);
  inputField.setAttribute("value", value);
  form.appendChild(inputField);
}

// Example usage:
// httpRequest('/help', {
//     user: 'peter' ,
//     cc: 'aus'
// });