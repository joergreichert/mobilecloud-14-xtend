package org.magnum.mobilecloud.video.servlet

import org.eclipse.xtend.lib.annotations.Accessors

class Html {
	@Accessors private Body body

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
	@Accessors private Form form

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
	@Accessors private String name
	@Accessors private FormMethod method
	@Accessors private String target
	@Accessors private FieldSet fieldset
	
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
	@Accessors private String legend
	@Accessors private Table table

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
	@Accessors private val labelAndValueList = <LabelAndValue>newArrayList
	@Accessors private val trs = <TR>newArrayList
	
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
	@Accessors private String id
	@Accessors private Label label
	@Accessors private Input input
	
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
	@Accessors private val tds = <TD>newArrayList
	
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
	@Accessors private Style style
	@Accessors private int colspan = -1
	@Accessors private Label label
	@Accessors private Input input
	
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
	@Accessors private TextAlign textAlign
	
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
	@Accessors private Input forInput
	@Accessors private String value
	
	def toHtml() '''<label«forInputToHtml»>«value»:&nbsp</label>'''

	def private forInputToHtml() {
		if(forInput?.id === null) "" else ''' for='«forInput.id»«"'"»'''
	} 
}

class Input {
	@Accessors private String id
	@Accessors private String name
	@Accessors private InputType type
	@Accessors private String value
	@Accessors private int maxLength = -1
	@Accessors private int size = -1
	
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
