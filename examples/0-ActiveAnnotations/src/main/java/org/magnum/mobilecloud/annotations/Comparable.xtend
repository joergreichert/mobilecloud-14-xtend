package org.magnum.mobilecloud.annotations

import com.google.common.base.Objects
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

import static extension org.magnum.mobilecloud.annotations.ActiveAnnotationsHelper.*

@Target(ElementType.TYPE)
@Active(ComparableProcessor)
annotation Comparable {
}

class ComparableProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val declaredFields = annotatedClass.getDeclaredFieldsWithoutIdAnnotation
		annotatedClass.addMethod("hashCode") [
			docComment = '''
				Two «annotatedClass.simpleName»s will generate the same hashcode if they have exactly the same values for their «declaredFields.getFieldNameList».
			'''
			returnType = primitiveInt
			body = '''
				// Google Guava provides great utilities for hashing 
				return «Objects».hashCode(«declaredFields.getFieldNameList»);
			'''
		]
		annotatedClass.addMethod("equals") [
			docComment = '''
				Two «annotatedClass.simpleName»s are considered equal if they have exactly the same values for their «declaredFields.getFieldNameList».
			'''
			returnType = primitiveBoolean
			addParameter("obj", object)
			body = '''
				if(obj instanceof «annotatedClass»){
					«annotatedClass» other = («annotatedClass») obj;
					// Google Guava provides great utilities for equals too!
					«val objectFields = declaredFields.filter[!type.primitive]» 
					«val primitiveFields = declaredFields.filter[type.primitive]» 
					return «objectFields.generateCompares[field | generateObjectCompare(field, context)]» 
							«IF !objectFields.empty && !primitiveFields.empty» && «ENDIF»«primitiveFields.generateCompares[field | generatePrimitiveCompare(field, context)]»;
				}
				else {
					return false;
				}
			'''
		]
	}
	
	def private generateCompares(Iterable<? extends MutableFieldDeclaration> fields, (MutableFieldDeclaration) => CharSequence compareFun) 
		'''«FOR field : fields SEPARATOR " && "»«compareFun.apply(field)»«ENDFOR»'''
	
	def private generateObjectCompare(MutableFieldDeclaration field, extension TransformationContext context) 
		'''«Objects.newTypeReference».equal(«field.simpleName», other.«field.asGetter(context)»)'''

	def private generatePrimitiveCompare(MutableFieldDeclaration field, extension TransformationContext context) 
		'''«field.simpleName» == other.«field.asGetter(context)»'''
		
	def private getFieldNameList(Iterable<? extends MutableFieldDeclaration> fields) {
		fields.map[simpleName].join(", ")
	}

	def private asGetter(MutableFieldDeclaration field, extension TransformationContext context) 
		'''«IF field.type == primitiveBoolean»is«ELSE»get«ENDIF»«(if(field.simpleName.startsWith("_")) field.simpleName.substring(1) else field.simpleName).toFirstUpper»()'''
	
}
