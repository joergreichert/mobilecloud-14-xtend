package org.magnum.mobilecloud.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension org.magnum.mobilecloud.annotations.ActiveAnnotationsHelper.*

@Target(ElementType.TYPE)
@Active(DefaultConstructorProcessor)
annotation DefaultConstructor {
	boolean generateEmpty = false
}

class DefaultConstructorProcessor extends AbstractClassProcessor {
	private boolean generateEmptyConstructor = false
	
	def setGenerateEmptyConstructor(boolean generateEmptyConstructor) {
		this.generateEmptyConstructor = generateEmptyConstructor
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val declaredFields = annotatedClass.getDeclaredFieldsWithoutIdAnnotation
		annotatedClass.addConstructor [
			declaredFields.forEach(f|addParameter(f.simpleName, f.type))
			body = '''
				«FOR fieldName : declaredFields.map[simpleName]»
					this.«fieldName» = «fieldName»;
				«ENDFOR»
			'''
		]
		val defaultConstructorAnnotation = annotatedClass.annotations.findAnnotation(DefaultConstructor)
		if((defaultConstructorAnnotation !== null && defaultConstructorAnnotation.getBooleanValue("generateEmpty")) || generateEmptyConstructor) {
			annotatedClass.addConstructor []
		}
	}
}
