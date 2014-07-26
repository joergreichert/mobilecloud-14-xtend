package org.magnum.mobilecloud.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(SerializableProcessor)
annotation Serializable {
}

class SerializableProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addField("serialVersionUID") [
				type = primitiveLong
				final = true
				static = true
				visibility = Visibility.PRIVATE
				initializer = '''1L'''
		]
	}
}
