package net.morocoshi.common.loaders.collada 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.nodes.ColladaScene;
	
	/**
	 * Collada(DAE)をパースしてM3D化しやすい形式にする
	 * 
	 * @author tencho
	 */
	public class ColladaParser 
	{
		//private var scene:ColladaScene;
		private var collector:ColladaCollector;
		
		public function ColladaParser() 
		{
		}
		
		public function parse(xml:XML, option:ColladaParseOption):ColladaScene 
		{
			
			collector = new ColladaCollector();
			collector.option = option;
			
			xml = ColladaUtil.deleteNameSpace(xml);
			var scene:ColladaScene = new ColladaScene();
			scene.parse(xml, collector);
			return scene;
		}
		
	}

}