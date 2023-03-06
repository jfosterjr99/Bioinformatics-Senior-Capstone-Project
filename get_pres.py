from flask import Flask, render_template, request, session, redirect
from flask_sqlalchemy import SQLAlchemy
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms import StringField, RadioField, SubmitField, SelectField
from wtforms.validators import DataRequired
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'thequickbrownfrog'

import jinja2

app = Flask(__name__)
app.config['SECRET_KEY'] = 'thequickbrownfrog'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = 'False'

##*****************************************##
## Connect to your local postgres database ##
##*****************************************##

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:jfosterjr99@localhost/myadvproject'


db = SQLAlchemy(app)
bootstrap = Bootstrap(app)


class SearchButton_Form(FlaskForm):
    submit = SubmitField('Go To Search')

class NameForm(FlaskForm):
    name1 = StringField('Enter MSI Gene Name', validators=[DataRequired()])
    name3 = SelectField('Limit Search Results By', choices=[('1', '1'), ('5', '5'), ('10', '10'),('50', '50')])
    submit = SubmitField('Submit')

class Data(db.Model):
    __tablename__ = "msi_gene"
    gene_name = db.Column(db.String(15),
                        primary_key=True,
                        index=False,
                        nullable=False)
    msi_val = db.Column(db.String(15),
                        index=False,
                        nullable=False)

    def __init__(self, gene_name, msi_val):
        self.gene_name = gene_name
        self.msi_val = msi_val

    def __repr__(self):
        return f"<msi_gene {self.gene_name}>"


@app.route("/", methods =['GET','POST'])
def index():
    form2 = SearchButton_Form()
    if request.method == 'POST':
        return redirect('/search')
    return render_template("index.html", form2=form2)

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_server_error(e):
    return render_template('500.html'), 500

@app.route("/results", methods = ['GET', 'POST'])
def presults():
    name1 = session.get('name1')
    name3 = session.get('name3')
    form3 = SearchButton_Form()

    searchterm = "%{}%".format(name1) ## adds % wildcards to front & back of search term
    displayorder = eval('Data.{}'.format('msi_val'))


    presults = Data.query.filter(Data.gene_name.like(searchterm)).order_by(displayorder).limit(name3).all()

    #presults = Data.query.all()
    #presults = Data.query.order_by(Data.first_name).all()
    #presults = Data.query.filter(Data.last_name == name1).order_by(Data.last_name).all()
    #presults = Data.query.filter_by(Data.last_name.like(searchterm)).order_by(displayorder).all()

    if request.method == 'POST':
        return redirect('/search')

    return render_template('pres_results.html', presults=presults,\
     name1=name1,name3=name3,form3=form3)


@app.route('/search', methods=['GET', 'POST'])
def search():
    name1 = None
    name3 = None
    form = NameForm()
    if form.validate_on_submit():
        if request.method == 'POST':
           session['name1']  = form.name1.data		# name1 is search term entered in first text box on form
           session['name3']  = form.name3.data		# name3 is to limit the number of results displayed in table
#          return '''<h1>The name1 value is: {}</h1>
#                  <h1>The name2  value is: {}</h1>'''.format(name1, name2)
           return redirect('/results')

        form.name1.data = ''	## Reset form values
        form.name3.data = ''
    return render_template('search.html', form=form)

if __name__ == "__main__":
    app.run(debug=True)
