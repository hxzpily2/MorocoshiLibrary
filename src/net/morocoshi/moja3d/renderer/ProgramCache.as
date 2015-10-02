package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	
	/**
	 * Program3Dのキャッシュを保存しておく場所
	 * 
	 * @author tencho
	 */
	public class ProgramCache 
	{
		static private var cache:Object = { };
		
		static public function removeProgram(key:String):void
		{
			delete cache[key];
		}
		
		static public function getProgram(context3D:Context3D, key:String):Program3D
		{
			return cache[key];
		}
		
	}

}