package org.magnum.mobilecloud.video.servlet

class Html {
	@Property private Body body

	def toStartHtml() 
		'''
			<html>
				«IF body !== null»«body.toStartHtml»«ENDIF»
		'''

	def toHtml() 
		'''
			<html>
				«IF body !== null»«body.toHtml»«ENDIF»
			</html>
		'''

	def toEndHtml() 
		'''
				«IF body !== null»«body.toEndHtml»«ENDIF»
			</html>
		'''
}

class Body {
	@Property private Form form

	def toStartHtml() 
		'''
			<body>
		'''

	def toHtml() 
		'''
			<body>
				«IF form !== null»«form.toHtml»«ENDIF»
			</body>
		'''

	def toEndHtml() 
		'''
			</body>
		'''
}

class Form {
	@Property private String name
	@Property private FormMethod method
	@Property private String target
	@Property private FieldSet fieldset
	
	def toHtml() 
		'''
			<form«nameToHtml»«methodToHtml»«targetToHtml»>
				«fieldset.toHtml»
			</form>
		'''

	def private nameToHtml() {
		if(name === null) "" else ''' name='«name»«"'"»'''
	} 

	def private methodToHtml() {
		if(method === null) "" else ''' method='«formMethodToString»«"'"»'''
	} 

	def private targetToHtml() {
		if(target === null) "" else ''' target='«target»«"'"»'''
	} 

	def private formMethodToString() {
		switch(it : method) {
			case GET: "GET"
			case POST: "POST"
		}
	}
}

enum FormMethod {  GET, POST }

class FieldSet {
	@Property private String legend
	@Property private Table table

	def toHtml() 
		'''
			<fieldset>
				«legendToHtml»
				«table.toHtml»
			</fieldset>
		'''
		
	def private legendToHtml() {
		if(legend === null) "" else '''<legend>«legend»</legend>'''
	} 
		
}

class Table {
	@Property private val labelAndValueList = <LabelAndValue>newArrayList
	@Property private val trs = <TR>newArrayList
	
	def toHtml() 
		'''
			<table>
				«FOR labelAndValue : labelAndValueList»
					«labelAndValue.toHtml»
				«ENDFOR»
				«FOR tr : trs»
					«tr.toHtml»
				«ENDFOR»
			<table>
		'''
}

class LabelAndValue {
	@Property private String id
	@Property private Label label
	@Property private Input input
	
	def toHtml() {
		(new TR => [
			tds += new TD => [
				label = this.label => [ forInput = this.input ]
			]
			tds += new TD => [
				input = this.input
			]
		]).toHtml
	} 
		
}

class TR {
	@Property private val tds = <TD>newArrayList
	
	def toHtml() 
		'''
			<tr>
				«FOR td : tds»
					«td.toHtml»
				«ENDFOR»
			</tr>
		'''
}

class TD {
	@Property private Style style
	@Property private int colspan = -1
	@Property private Label label
	@Property private Input input
	
	def toHtml() 
		'''
			<td«styleToHtml»«colspanToHtml»>
				«IF label !== null»«label.toHtml»«ELSEIF input !== null»«input.toHtml»«ENDIF»
			</td>
		'''

	def private styleToHtml() {
		if(style === null) "" else ''' «style.toHtml»'''
	} 
	
	def private colspanToHtml() {
		if(colspan == -1) "" else ''' «colspanToString»'''
	} 

	def private colspanToString() {
		switch(it : colspan) {
			case -1: ""
			default: String.valueOf(it)
		}
	}
}

class Style {
	@Property private TextAlign textAlign
	
	def toHtml() 
		'''
			«IF textAlign !== null»style='«textAlignToHtml»«"'"»«ENDIF»
		'''

	def private textAlignToHtml() {
		if(textAlign === null) "" else ''' text-align: «textAlignToString»'''
	} 

	def private textAlignToString() {
		switch(it : textAlign) {
			case LEFT: "left"
			case CENTER: "center"
			case RIGHT: "right"
		}
	}
}

enum TextAlign {
	LEFT, CENTER, RIGHT
}

class Label {
	@Property private Input forInput
	@Property private String value
	
	def toHtml() '''<label«forInputToHtml»>«value»:&nbsp</label>'''

	def private forInputToHtml() {
		if(forInput?.id === null) "" else ''' for='«forInput.id»«"'"»'''
	} 
}

class Input {
	@Property private String id
	@Property private String name
	@Property private InputType type
	@Property private String value
	@Property private int maxLength = -1
	@Property private int size = -1
	
	def toHtml() 
		'''
			<input«typeToHtml»«nameToHtml»«idToHtml»«valueToHtml»«sizeToHtml»«maxLengthToHtml» />
		'''

	def private typeToHtml() {
		if(type === null) "" else ''' type='«typeToString»«"'"»'''
	} 

	def private nameToHtml() {
		if(name === null) "" else ''' name='«name»«"'"»'''
	} 

	def private idToHtml() {
		if(id === null) "" else ''' id='«id»«"'"»'''
	} 
	
	private def typeToString() {
		switch(it : type) {
			case TEXT: "text"
			case SUBMIT: "submit"
		}
	}

	def private valueToHtml() {
		if(value === null) "" else ''' value='«value»«"'"»'''
	} 

	def private sizeToHtml() {
		if(size == -1) "" else ''' size='«size»«"'"»'''
	} 

	def private maxLengthToHtml() {
		if(maxLength == -1) "" else ''' maxlength='«maxLength»«"'"»'''
	} 
}

enum InputType {
	TEXT, SUBMIT
}
