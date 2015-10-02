package net.morocoshi.moja3d.utils 
{
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.adobe.AGALMiniAssembler;
	import net.morocoshi.moja3d.adobe.AGALMiniAssembler2;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AssemblerUtil 
	{
		static private var assembler:AGALMiniAssembler2 = new AGALMiniAssembler2();
		
		public function AssemblerUtil() 
		{
		}
		
		static public function assembleVertexCode(code:String, version:uint):ByteArray
		{
			return assembler.assemble(Context3DProgramType.VERTEX, code, version);
		}
		
		static public function assembleFragmentCode(code:String, version:uint):ByteArray
		{
			return assembler.assemble(Context3DProgramType.FRAGMENT, code, version);
		}
		
	}

}