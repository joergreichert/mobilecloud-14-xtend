package org.magnum.mobilecloud.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(SimpleLiteralProcessor)
annotation SimpleLiteral {
}

class SimpleLiteralProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.declaredFields.map[simpleName.substring(1)].forEach(oldFieldName|
			annotatedClass.addField('''PARAM_«oldFieldName»''') [
				docComment = '''Name of field «oldFieldName»'''
				type = string
				final = true
				static = true
				visibility = Visibility.PUBLIC
				initializer = '''"«oldFieldName»"'''
			]
		)
	}
}
