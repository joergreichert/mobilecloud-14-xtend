package org.magnum.mobilecloud.annotations

import de.oehme.xtend.contrib.PropertyProcessor
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension org.magnum.mobilecloud.annotations.ActiveAnnotationsHelper.*

@Target(ElementType.TYPE)
@Active(DataProcessor)
annotation Data {
	boolean generateEmptyConstructor = false	
}

class DataProcessor extends AbstractClassProcessor {
	private DefaultConstructorProcessor defaultConstructorProcessor = new DefaultConstructorProcessor
	private PropertyProcessor propertyProcessor = new PropertyProcessor
	private ComparableProcessor comparableProcessor = new ComparableProcessor

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val generateEmptyConstructor = annotatedClass.annotations.findAnnotation(Data).getBooleanValue("generateEmptyConstructor")
		defaultConstructorProcessor.generateEmptyConstructor = generateEmptyConstructor
		defaultConstructorProcessor.doTransform(annotatedClass, context)
		annotatedClass.declaredFields.forEach[propertyProcessor.doTransform(it, context)]
		comparableProcessor.doTransform(annotatedClass, context)
	}
}
