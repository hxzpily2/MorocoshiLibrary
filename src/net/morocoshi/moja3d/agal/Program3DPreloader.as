package net.morocoshi.moja3d.agal 
{
	import flash.display3D.Context3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * Program3Dの事前生成
	 * 
	 * @author tencho
	 */
	public class Program3DPreloader 
	{
		
		public function Program3DPreloader() 
		{
		}
		
		public function load(object:Object3D, context3D:ContextProxy):void 
		{
			var collector:RenderCollector = new RenderCollector();
			collector.context3D = context3D;
			
			//初回チェック
			collector.renderPhase = RenderPhase.CHECK;
			collector.clear();
			collector.setBasicContext();
			object.collectRenderElements(collector, false, false, false, 1, object.containerRenderMask);
			collector.complete();
			
			//影要素
			if (collector.hasShadowElement && collector.sunShadowList.length)
			{
				collector.renderPhase = RenderPhase.SHADOW;
				collector.clear();
				collector.setBasicContext();
				object.collectRenderElements(collector, false, false, false, 1, object.containerRenderMask);
				collector.complete();
			}
			
			//反射要素
			if (collector.reflectiveWater.hasReflectElement)
			{
				collector.renderPhase = RenderPhase.REFLECT;
				collector.clear();
				collector.setBasicContext();
				object.collectRenderElements(collector, false, false, false, 1, object.containerRenderMask);
				collector.complete();
			}
			
			//通常要素
			collector.renderPhase = RenderPhase.NORMAL;
			collector.clear();
			collector.setBasicContext();
			object.collectRenderElements(collector, false, false, false, 1, object.containerRenderMask);
			collector.complete();
		}
		
	}

}