package net.morocoshi.moja3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALCache;
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALInfo;
	import net.morocoshi.moja3d.agal.UsingConstants;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.core.AlphaPassShader;
	import net.morocoshi.moja3d.shaders.core.OpaquePassShader;
	import net.morocoshi.moja3d.shaders.render.KillShader;
	import net.morocoshi.moja3d.shaders.render.LightShader;
	import net.morocoshi.moja3d.shaders.render.ReflectionShader;
	import net.morocoshi.moja3d.shaders.shadow.ShadowShader;
	import net.morocoshi.moja3d.utils.AssemblerUtil;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * シェーダーリスト管理
	 * 
	 * @author tencho
	 */
	public class ShaderList 
	{
		private var _alphaState:uint;
		private var _vertexCode:AGALCode;
		private var _fragmentCode:AGALCode;
		private var _reflectShader:ReflectionShader;
		private var _shadowShader:ShadowShader;
		private var _lightShader:LightShader;
		private var _key:String;
		
		moja3d var shaders:Vector.<MaterialShader>;
		private var tickShaderList:Vector.<MaterialShader>;
		public var name:String = "";
		private var initialized:Boolean;
		
		public var vertexUsingConstants:UsingConstants;
		public var fragmentUsingConstants:UsingConstants;
		
		moja3d var existTickShader:Boolean;
		
		moja3d var updateKeyOrder:Boolean;
		moja3d var updateConstantOrder:Boolean;
		moja3d var updateAlphaModeOrder:Boolean;
		/**反射シェーダー関連に変更があったらtrueにする*/
		moja3d var updatedReflectElement:Boolean;
		/**影のキャスト状況に変更があったらtrueにする*/
		moja3d var updatedShadowElement:Boolean;
		moja3d var updatedLightElement:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ShaderList(list:Array = null) 
		{
			_alphaState = AlphaState.UNKNOWN;
			_reflectShader = null;
			
			initialized = false;
			
			existTickShader = false;
			updateKeyOrder = true;
			updateAlphaModeOrder = true;
			updateConstantOrder = true;
			updatedReflectElement = true;
			updatedShadowElement = true;
			updatedLightElement = true;
			
			tickShaderList = new Vector.<MaterialShader>;
			shaders = new Vector.<MaterialShader>;
			_vertexCode = new AGALCode(Context3DProgramType.VERTEX);
			_fragmentCode = new AGALCode(Context3DProgramType.FRAGMENT);
			vertexUsingConstants = new UsingConstants();
			fragmentUsingConstants = new UsingConstants();
			
			//コンストラクタ引数でシェーダーを追加する場合
			if (list != null)
			{
				var n:int = list.length;
				for (var i:int = 0; i < n; i++) 
				{
					addShader(list[i]);
				}
			}
		}
		
		/**
		 * メモリ解放
		 */
		public function finaly():void 
		{
			removeAllShader();
			
			_alphaState = 0;
			_vertexCode = null;
			_fragmentCode = null;
			_reflectShader = null;
			_shadowShader = null;
			_lightShader = null;
			_key = null;
			name = null;
			vertexUsingConstants = null;
			fragmentUsingConstants = null;
			
			DataUtil.deleteVector(shaders);
			DataUtil.deleteVector(tickShaderList);
			shaders = null;
			tickShaderList = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get numShaders():int
		{
			return shaders.length;
		}
		
		public function get vertexCode():AGALCode 
		{
			if (updateConstantOrder)
			{
				updateConstantList();
			}
			return _vertexCode;
		}
		
		public function get fragmentCode():AGALCode 
		{
			if (updateConstantOrder)
			{
				updateConstantList();
			}
			return _fragmentCode;
		}
		
		public function get alphaState():uint 
		{
			if (updateAlphaModeOrder)
			{
				updateAlphaState();
			}
			return _alphaState;
		}
		
		public function get lightShader():LightShader
		{
			if (updatedLightElement)
			{
				updatedLightElement = false;
				updateLightElement();
			}
			return _lightShader;
		}
		
		public function get shadowShader():ShadowShader 
		{
			if (updatedShadowElement)
			{
				updatedShadowElement = false;
				updateShadowElement();
			}
			return _shadowShader;
		}
		
		public function get reflectShader():ReflectionShader 
		{
			if (updatedReflectElement)
			{
				updateReflectElement();
			}
			return _reflectShader;
		}
		
		public function get key():String 
		{
			if (updateKeyOrder)
			{
				updateKey();
			}
			/*
			if (updateAlphaModeOrder)
			{
				updateAlphaMode();
				updateConstantList();
			}
			*/
			return _key;
		}
		
		public function updateKey():void 
		{
			updateKeyOrder = false;
			
			_key = "";
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader.enabled == false || shader.valid == false) continue;
				_key += shader.getKey() + "|";
			}
			_key += alphaState;
		}
		
		//--------------------------------------------------------------------------
		//
		//  追加/削除
		//
		//--------------------------------------------------------------------------
		
		public function getShaderAs(classType:Class):MaterialShader
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader is classType)
				{
					return shader;
				}
			}
			return null;
		}
		
		public function removeShaderAs(classType:Class):Boolean 
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader is classType)
				{
					return removeShader(shader);
				}
			}
			return false;
		}
		
		/**
		 * i番目のシェーダーを取得
		 * @param	i
		 * @return
		 */
		public function getShaderAt(i:int):MaterialShader
		{
			return shaders[i];
		}
		
		/**
		 * 最後にシェーダーを追加
		 * @param	shader
		 * @return
		 */
		public function addShader(shader:MaterialShader):MaterialShader
		{
			if (shaders.indexOf(shader) >= 0) return shader;
			
			shader.addShaderListener(this);
			shaders.push(shader);
			updateConstantOrder = true;
			updateAlphaModeOrder = true;
			updateKey();
			
			return shader;
		}
		
		public function addShaderAt(i:int, shader:MaterialShader):MaterialShader
		{
			if (shaders.indexOf(shader) > 0) return shader;
			
			shader.addShaderListener(this);
			shaders.splice(i, 0, shader);
			updateConstantOrder = true;
			updateAlphaModeOrder = true;
			
			return shader;
		}
		
		/**
		 * 水面反射用のKillShaderがなければ追加する
		 * @param	shader
		 * @return
		 */
		public function addKillShader(shader:KillShader):KillShader
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:MaterialShader = shaders[i];
				if (item is KillShader)
				{
					return shader;
				}
			}
			addShader(shader);
			updateKey();
			
			return shader;
		}
		
		/**
		 * 指定のシェーダーが配列にあれば削除
		 * @param	shader
		 */
		public function removeShader(shader:MaterialShader):Boolean
		{
			var index:int = shaders.indexOf(shader);
			if (index == -1) return false;
			
			shader.removeShaderListener(this);
			shaders.splice(index, 1);
			updateConstantOrder = true;
			updateAlphaModeOrder = true;
			
			return true;
		}
		
		public function removeShaders(list:Vector.<MaterialShader>):int
		{
			var count:int = 0;
			var n:int = list.length
			for (var i:int = 0; i < n; i++) 
			{
				if (removeShader(list[i])) count++;
			}
			updateKey();
			return count;
		}
		
		/**
		 * 全てのシェーダーをリストから外して関連付けをなくす
		 */
		public function removeAllShader():void
		{
			while (shaders.length)
			{
				removeShader(shaders[0]);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function getFragmentConstantIndex(id:String):int
		{
			var link:Object = AGALCache.fragmentConstant[_key];
			if (link == null || link[id] === undefined)
			{
				return -1;
			}
			
			return link[id];
		}
		
		public function getVertexConstantIndex(id:String):int
		{
			var link:Object = AGALCache.vertexConstant[_key];
			if (link == null || link[id] === undefined)
			{
				return -1;
			}
			
			return link[id];
		}
		
		/**
		 * 
		 * @param	collector
		 * @return
		 */
		public function getProgram(collector:RenderCollector):Program3D
		{
			var program:Program3D = AGALCache.program[_key];
			if (program == null)
			{
				AGALCache.program[_key] = program = createProgram(collector.context3D, collector.info, collector.vertexCode, collector.fragmentCode);
				AGALCache.vertexConstant[_key] = _vertexCode.constantIndexLink;
				AGALCache.fragmentConstant[_key] = _fragmentCode.constantIndexLink;
			}
			
			if (initialized == false)
			{
				initialized = true;
				var n:int = shaders.length;
				for (var i:int = 0; i < n; i++) 
				{
					shaders[i].afterCreateProgram(this);
				}
			}
			
			return program;
		}
		
		/**
		 * 参照
		 * @return
		 */
		public function reference():ShaderList 
		{
			var result:ShaderList = new ShaderList();
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.addShader(shaders[i]);
			}
			return result;
		}
		
		/**
		 * 複製(ここをちゃんとコピーするようにしたい)
		 * @param	cloneResources	リソースも複製する
		 * @return
		 */
		public function clone(cloneResources:Boolean = true):ShaderList 
		{
			var result:ShaderList = new ShaderList();
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = cloneResources? shaders[i].clone() : shaders[i].reference();
				result.addShader(shader);
			}
			return result;
		}
		
		/**
		 * 全てのシェーダーのtick()を実行する。
		 * @param	frame
		 * @param	timer
		 */
		public function tick(frame:int, timer:int):void 
		{
			var n:int = tickShaderList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = tickShaderList[i];
				if (frame == shader.lastFrame) continue;
				
				shader.lastFrame = frame;
				shader.tick(timer);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 光シェーダーが含まれているかチェックする
		 */
		private function updateLightElement():void
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader.enabled && shader.valid && shader.hasLightElement)
				{
					_lightShader = shader as LightShader;
					return;
				}
			}
			_lightShader = null;
		}
		
		/**
		 * 影シェーダーが含まれているかチェックする
		 */
		private function updateShadowElement():void
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader.enabled && shader.valid && shader.hasShadowElement)
				{
					_shadowShader = shader as ShadowShader;
					return;
				}
			}
			_shadowShader = null;
		}
		
		private function updateReflectElement():void 
		{
			updatedReflectElement = false;
			_reflectShader = null;
			
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader.enabled && shader.valid && shader.hasReflectElement)
				{
					_reflectShader = shader as  ReflectionShader;
					return;
				}
			}
		}
		
		private function updateAlphaState():void
		{
			updateAlphaModeOrder = false;
			_alphaState = AlphaState.UNKNOWN;
			
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				switch(shaders[i].alphaTransform)
				{
					case AlphaTransform.SET_OPAQUE:
						_alphaState = AlphaState.OPAQUE;
						break;
					case AlphaTransform.SET_TRANSPARENT:
						_alphaState = AlphaState.TRANSPARENT;
						break;
					case AlphaTransform.SET_MIXTURE:
						_alphaState = AlphaState.MIXTURE;
						break;
					case AlphaTransform.SET_UNKNOWN:
						_alphaState = AlphaState.UNKNOWN;
						break;
					case AlphaTransform.MUL_TRANSPARENT:
						if (_alphaState != AlphaState.UNKNOWN)
						{
							_alphaState = AlphaState.TRANSPARENT;
						}
						break;
				}
				
			}
			if (_alphaState == AlphaState.UNKNOWN)
			{
				_alphaState = AlphaState.MIXTURE;
			}
		}
		
		/**
		 * 各シェーダーが持つ必須アトリビュートがジオメトリ内に存在するかチェックし、必要なら無効なシェーダーをリストから削除する。
		 * @param	geom
		 * @return
		 */
		public function updateFromGeometry(geom:Geometry):Vector.<MaterialShader>
		{
			var n:int = shaders.length;
			
			var removeList:Vector.<MaterialShader> = new Vector.<MaterialShader>;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				var valid:Boolean = true;
				var m:int = shader.requiredAttribute.length;
				for (var j:int = 0; j < m; j++) 
				{
					if (geom.hasAttribute(shader.requiredAttribute[j]) == false)
					{
						valid = false;
						break;
					}
				}
				if (valid == false)
				{
					removeList.push(shader);
				}
			}
			if (removeList.length > 0)
			{
				removeShaders(removeList);
				updateKey();
			}
			
			updateConstantList();
			return removeList;
		}
		
		/**
		 * シェーダーリストが持つ定数情報とかを連結してまとめる
		 */
		public function updateConstantList():void
		{
			updateConstantOrder = false;
			
			_vertexCode.clearAll();
			_fragmentCode.clearAll();
			vertexUsingConstants.clear();
			fragmentUsingConstants.clear();
			//_key = "";
			
			tickShaderList.length = 0;
			existTickShader = false;
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				if (shader.enabled == false || shader.valid == false) continue;
				
				if (shader.tickEnabled)
				{
					tickShaderList.push(shader);
					existTickShader = true;
				}
				_vertexCode.attachConstant(shader.vertexCode);
				_fragmentCode.attachConstant(shader.fragmentCode);
				vertexUsingConstants.attach(shader.vertexConstants);
				fragmentUsingConstants.attach(shader.fragmentConstants);
				//_key += shader.getKey() + "|";
			}
			//_key += _alphaMode;
			updateKey();
			initialized = false;
		}
		
		/**
		 * 他のシェーダーリストの参照をここに追加する
		 * @param	shaderList
		 * @param	filterGeometry
		 */
		public function attach(shaderList:ShaderList, filterGeometry:Geometry = null):void 
		{
			var n:int = shaderList.numShaders;
			for (var i:int = 0; i < n; i++) 
			{
				addShader(shaderList.getShaderAt(i));
			}
		}
		
		/**
		 * 
		 * @param	shaderList
		 * @param	phase
		 */
		public function attachExtra(shaderList:ShaderList, phase:String):void 
		{
			var n:int = shaderList.numShaders;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaderList.getShaderAt(i).getExtraShader(phase);
				if (shader)
				{
					addShader(shader);
				}
			}
		}
		
		/**
		 * 
		 * @param	material
		 * @return
		 */
		public function cloneWithOpaque(material:Material):ShaderList 
		{
			var opaquePass:OpaquePassShader = new OpaquePassShader(material.alphaThreshold);
			material.opaquePassConst = opaquePass.thresholdConst;
			var shaderList:ShaderList = reference();
			shaderList.addShaderAt(shaderList.numShaders - 1, opaquePass);
			shaderList.updateConstantList();
			return shaderList;
		}
		
		/**
		 * 
		 * @param	material
		 * @return
		 */
		public function cloneWithAlpha(material:Material):ShaderList 
		{
			var alphaPass:AlphaPassShader = new AlphaPassShader(material.alphaThreshold);
			material.alphaPassConst = alphaPass.thresholdConst;
			var shaderList:ShaderList = reference();
			shaderList.addShaderAt(shaderList.numShaders - 1, alphaPass);
			shaderList.updateConstantList();
			return shaderList;
		}
		
		/**
		 * Program3Dを生成します
		 * @param	context3D
		 * @param	info
		 * @param	rootVertex
		 * @param	rootFragment
		 * @return
		 */
		private function createProgram(context3D:ContextProxy, info:AGALInfo, rootVertex:AGALCode, rootFragment:AGALCode):Program3D 
		{
			var program:Program3D = context3D.context.createProgram();
			_vertexCode.codeLines.length = 0;
			_fragmentCode.codeLines.length = 0;
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (shaders[i].enabled == false || shaders[i].valid == false) continue;
				_vertexCode.attachCode(shaders[i].vertexCode);
				_fragmentCode.attachCode(shaders[i].fragmentCode);
			}
			
			var vertex:String = _vertexCode.getCode(rootVertex, info, null, _fragmentCode.usedVarying);
			var fragment:String = _fragmentCode.getCode(rootFragment, info, _vertexCode.varyingKey, null);
			checkOpecodeLine(context3D, info, vertex, true);
			checkOpecodeLine(context3D, info, fragment, false);
			
			try
			{
				var vertexData:ByteArray = AssemblerUtil.assembleVertexCode(vertex, info.version);
				var fragmentData:ByteArray = AssemblerUtil.assembleFragmentCode(fragment, info.version);
				program.upload(vertexData, fragmentData);
			}
			catch (e:Error)
			{
				var shaderText:String = "";
				n = shaders.length;
				for (i = 0; i < n; i++) 
				{
					shaderText += String(shaders[i]) + "\n";
				}
				throw new Error(name + "\n=================================\n" + shaderText + "\n" + toTracedCode(vertex) + "\n---------------------------------\n" + toTracedCode(fragment) + "\n---------------------------------\n" + e);
			}
			return program;
		}
		
		/**
		 * オペコード限界チェック
		 * @param	context3D
		 * @param	info
		 * @param	code
		 * @param	vertex
		 */
		private function checkOpecodeLine(context3D:ContextProxy, info:AGALInfo, code:String, vertex:Boolean):void 
		{
			var num:int = code.split("\n").length;
			if (num > info.maxTokens)
			{
				var type:String = vertex? "頂点シェーダ" : "フラグメントシェーダ";
				throw new Error(type + "でオペコードの行数が" + info.maxTokens + "を超えています。(" + num + ") at " + _key);
			}
		}
		
		/**
		 * 
		 * @param	code
		 * @return
		 */
		private function toTracedCode(code:String):String 
		{
			var result:Array = [];
			var list:Array = code.split("\n");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.push((i + 1) + ":" + list[i]);
			}
			return result.join("\n");
		}
	}

}