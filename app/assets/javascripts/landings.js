(function(){
	$(document).ready(function(){
		$('#join_waitlist_fb_land').click(function() {
		  FB.login(function(response) {
		    var appsecretProof = $.ajax({
		                                  url: "/waitlists/create_appsecret_proof",
		                                  type: "post",
		                                  data: {access_token: response.authResponse.accessToken},
		                                  async: false,
		                                  success: function(response2) {
		                                    return response2
		                                  }
		                                })

		    FB.api('/me', {fields: 'name,email', appsecret_proof: appsecretProof["responseText"]}, function(response3) {
		      var name = response3["name"]
		      var email = response3["email"]
		      var id = response3["id"]
		      var form = $('<form action="/waitlists/create" method="post" style="display: hidden" id="form"><input type="hidden" id="name" name="name" value=""><input type="hidden" id="email" name="email" value=""><input type="hidden" id="id" name="id" value=""></form>')
		      $('body').append(form)
		      $("#name").val(name)
		      $("#email").val(email)
		      $("#id").val(id)
		      form.submit()
		    })
		  }, {scope: 'email', return_scopes: true})
		});		
	})

})()

