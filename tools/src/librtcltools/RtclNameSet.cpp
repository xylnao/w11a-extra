// $Id: RtclNameSet.cpp 374 2011-03-27 17:02:47Z mueller $
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
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclNameSet.cpp 374 2011-03-27 17:02:47Z mueller $
  \brief   Implemenation of RtclNameSet.
*/

// debug
#include <iostream>

#include <stdexcept>

#include "RtclNameSet.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RtclNameSet
  \brief FIXME_docs
*/

typedef std::pair<Retro::RtclNameSet::nset_it_t, bool>  nset_ins_t;

//------------------------------------------+-----------------------------------
//! Default constructor

RtclNameSet::RtclNameSet()
  : fSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclNameSet::RtclNameSet(const std::string& nset)
  : fSet()
{
  size_t ibeg=0;
  while (true) {
    size_t iend = nset.find_first_of('|', ibeg);
    if (iend-ibeg > 0) {
      string name(nset, ibeg, iend-ibeg);
      nset_ins_t ret = fSet.insert(name);
        if (ret.second == false)                  // or use !(ret.second)
          throw logic_error(string("RtclNameSet::<ctor> duplicate name '") +
                            name + string("' in set '") + nset + string("'"));
    }
    if (iend == string::npos) break;
    ibeg = iend+1;
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclNameSet::~RtclNameSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclNameSet:: Check(Tcl_Interp* interp, std::string& rval,
                         const std::string& tval) const
{
  rval.clear();
  nset_cit_t it = fSet.lower_bound(tval);

  // no leading substring match
  if (it==fSet.end() || tval!=it->substr(0,tval.length())) {
    Tcl_AppendResult(interp, "-E: bad option \"", tval.c_str(),
                     "\": must be ", NULL);
    const char* delim = "";
    for (nset_cit_t it1=fSet.begin(); it1!=fSet.end(); it1++) {
      Tcl_AppendResult(interp, delim, it1->c_str(), NULL);
      delim = ",";
    }
    return false;
  }

  // check for ambiguous substring match
  if (tval != *it) {
    nset_cit_t it1 = it;
    it1++;
    if (it1!=fSet.end() && tval==it1->substr(0,tval.length())) {
      Tcl_AppendResult(interp, "-E: ambiguous option \"", tval.c_str(),
                       "\": must be ", NULL);
      const char* delim = "";
      for (it1=it; it1!=fSet.end() &&
             tval==it1->substr(0,tval.length()); it1++) {
        Tcl_AppendResult(interp, delim, it1->c_str(), NULL);
        delim = ",";
      }
      return false;
    }
  }
  
  rval = *it;  
  return true;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RtclNameSet_NoInline))
#define inline
#include "RtclNameSet.ipp"
#undef  inline
#endif
