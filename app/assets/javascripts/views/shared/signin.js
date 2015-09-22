Cocktailist.Views.SignIn = Backbone.CompositeView.extend({
  template: JST['shared/signIn'],

  events: {
    "submit form": "submit"
  },

  initialize: function (options){
    this.callback = options.callback;
    this.listenTo(Cocktailist.currentUser, "signIn", this.signInCallback);
  },

  render: function (){
    this.$el.html(this.template());
    return this;
  },

  submit: function (e){
    e.preventDefault();
    var $form = $(e.currentTarget);
    var formData = $form.serializeJSON().user;
    Cocktailist.currentUser.signIn({
      email: formData.email,
      password: formData.password,
      error: function(){
        alert("Wrong username/password combination. Please try again.");
      }
    });
  },

  signInCallback: function (){
    if(this.callback) {
      this.callback();
    } else {
      Backbone.history.navigate("", { trigger: true });
    }
  }

});