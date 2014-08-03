package org.magnum.mobilecloud.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.springframework.boot.SpringApplication

@Target(ElementType.TYPE)
@Active(SpringRunProcessor)
annotation SpringRun {
}

class SpringRunProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addMethod("main") [
			docComment = "Tell Spring to launch our app!"
			static = true
			visibility = Visibility.PUBLIC
			addParameter("args", string.newArrayTypeReference)
			body = '''«SpringApplication».run(«annotatedClass».class, args);'''
		]
	}
}
