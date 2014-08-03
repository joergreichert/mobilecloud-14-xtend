package org.magnum.mobilecloud.annotations

import javax.persistence.Id
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

class ActiveAnnotationsHelper {
	
	def static getDeclaredFieldsWithoutIdAnnotation(MutableClassDeclaration annotatedClass) {
		annotatedClass.declaredFields.filter[annotations.findAnnotation(Id) == null]
	}
	
	def static findAnnotation(Iterable<? extends AnnotationReference> annotations, Class<?> clazz) {
		annotations.findFirst[it.annotationTypeDeclaration.qualifiedName == clazz.canonicalName]
	}	
}