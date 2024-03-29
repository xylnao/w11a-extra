// $Id: RtclProxyOwned.hpp 365 2011-02-28 07:28:26Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-13   361   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclProxyOwned.hpp 365 2011-02-28 07:28:26Z mueller $
  \brief   Declaration of class RtclProxyOwned.
*/

#ifndef included_Retro_RtclProxyOwned
#define included_Retro_RtclProxyOwned 1

#include "RtclProxyBase.hpp"

namespace Retro {

  template <class TO>
  class RtclProxyOwned : public RtclProxyBase {
    public:
                    RtclProxyOwned();
                    RtclProxyOwned(const std::string& type);
                    RtclProxyOwned(const std::string& type, Tcl_Interp* interp,
                                   const char* name, TO* pobj=0);
                    ~RtclProxyOwned();

      TO&           Obj();

    protected:
      void          SetObj(TO* pobj);

    protected:
      TO*           fpObj;                  //!< ptr to managed object


  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclProxyOwned.ipp"

#endif
